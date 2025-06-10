import os
import re
import argparse

class Cleaner:
    def __init__(self, options):
        self.options = options
        self.patterns = self._build_patterns()

    def _build_patterns(self):
        patterns = []

        # Скрытые символы
        if self.options.transform_hidden:
            patterns.append((
                re.compile(r'[\u00AD\u180E\u200B-\u200F\u202A-\u202E\u2060\u2066-\u2069\uFEFF]'),
                ''
            ))

        # Пробелы в конце строк
        if self.options.transform_trailing_whitespace:
            patterns.append((
                re.compile(r'[ \t\x0B\f]+$', flags=re.MULTILINE),
                ''
            ))

        # Неразрывные пробелы
        if self.options.transform_nbs:
            patterns.append((
                re.compile(r'[\u00A0]'),
                ' '
            ))

        # Тире
        if self.options.transform_dashes:
            patterns.append((
                re.compile(r'[—–]'),  # EM DASH и EN DASH
                '-'
            ))

        # Кавычки
        if self.options.transform_quotes:
            patterns.extend([
                (re.compile(r'[“”«»„]'), '"'),  # Двойные кавычки
                (re.compile(r'[‘’ʼ]'), "'")     # Одинарные кавычки
            ])

        # Прочие символы
        if self.options.transform_other:
            patterns.append((
                re.compile(r'[…]'),
                '...'
            ))

        return patterns

    def clean_text(self, text):
        original = text

        # Применяем все выбранные преобразования
        for pattern, replacement in self.patterns:
            text = pattern.sub(replacement, text)

        # Фильтр "только клавиатурные символы"
        if self.options.keyboard_only:
            keyboard_pattern = re.compile(
                r'([^\w\s'  # Базовые символы
                r'~`!@#№\$€£%\^&\*\(\)_\+-=\[\]\{\}\\\|;:\'",<\.>/\?]'  # Спецсимволы
                r'|\n)'     # Переносы строк
            )
            text = keyboard_pattern.sub('', text)

        return text, original != text

def process_file(file_path, cleaner):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        cleaned_content, changed = cleaner.clean_text(content)

        if not changed:
            return False

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(cleaned_content)
        return True

    except Exception as e:
        print(f"Ошибка обработки {file_path}: {str(e)}")
        return False

def process_directory(directory, options):
    cleaner = Cleaner(options)
    total = 0
    cleaned = 0

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                total += 1
                if process_file(file_path, cleaner):
                    cleaned += 1
                    print(f"Очищен: {file_path}")

    print(f"\nИтоги:")
    print(f"Обработано файлов: {total}")
    print(f"Изменено файлов: {cleaned}")
    print(f"Настройки: {vars(options)}")

def main():
    parser = argparse.ArgumentParser(description='Очистка Markdown файлов от специальных символов')
    parser.add_argument('directory', nargs='?', default='.', help='Целевая директория')

    # Опции преобразований
    parser.add_argument('--no-hidden', dest='transform_hidden', action='store_false', help='Не удалять скрытые символы')
    parser.add_argument('--no-trailing', dest='transform_trailing_whitespace', action='store_false', help='Не удалять пробелы в конце строк')
    parser.add_argument('--no-nbs', dest='transform_nbs', action='store_false', help='Не преобразовывать неразрывные пробелы')
    parser.add_argument('--no-dashes', dest='transform_dashes', action='store_false', help='Не нормализовать тире')
    parser.add_argument('--no-quotes', dest='transform_quotes', action='store_false', help='Не нормализовать кавычки')
    parser.add_argument('--no-other', dest='transform_other', action='store_false', help='Не преобразовывать прочие символы')
    parser.add_argument('--keyboard-only', action='store_true', help='Оставлять только клавиатурные символы')

    args = parser.parse_args()
    process_directory(args.directory, args)

if __name__ == '__main__':
    main()