# Скрипты для автоматической установки dotfiles

## Вариант 1: Простой Fish скрипт

Создайте файл `install.fish` в вашем dotfiles репозитории:

```fish
#!/usr/bin/env fish

# install.fish - скрипт для быстрого восстановления dotfiles

set -l DOTFILES_REPO "git@github.com:rmuhamedgaliev/dotfiles.git"
set -l DOTFILES_DIR "$HOME/.dotfiles"

echo "🐟 Установка dotfiles..."

# Проверяем наличие Fish
if not command -v fish >/dev/null
    echo "❌ Fish shell не установлен. Установите Fish сначала."
    exit 1
end

# Проверяем наличие Git
if not command -v git >/dev/null
    echo "❌ Git не установлен. Установите Git сначала."
    exit 1
end

# Удаляем существующую директорию dotfiles если есть
if test -d $DOTFILES_DIR
    echo "🗑️  Удаляем существующую директорию dotfiles..."
    rm -rf $DOTFILES_DIR
end

# Клонируем репозиторий
echo "📥 Клонирование dotfiles репозитория..."
git clone --bare $DOTFILES_REPO $DOTFILES_DIR

# Создаем временный алиас
alias dotfiles="/usr/bin/git --git-dir=$DOTFILES_DIR --work-tree=$HOME"

# Создаем бэкап существующих файлов
echo "💾 Создание бэкапа существующих конфигураций..."
set -l backup_dir "$HOME/.config-backup-"(date +%Y%m%d-%H%M%S)

if dotfiles checkout 2>/dev/null
    echo "✅ Checkout выполнен успешно"
else
    echo "⚠️  Найдены конфликтующие файлы, создаем бэкап в $backup_dir"
    mkdir -p $backup_dir
    
    # Получаем список конфликтующих файлов и перемещаем их в бэкап
    dotfiles checkout 2>&1 | grep -E "^\s+" | awk '{print $1}' | while read -l file
        if test -f "$HOME/$file"
            set -l dir (dirname "$backup_dir/$file")
            mkdir -p $dir
            mv "$HOME/$file" "$backup_dir/$file"
            echo "  📦 $file -> $backup_dir/$file"
        end
    end
    
    # Повторяем checkout
    dotfiles checkout
end

# Настраиваем git
echo "⚙️  Настройка git конфигурации..."
dotfiles config --local status.showUntrackedFiles no

# Добавляем алиас в Fish конфигурацию
echo "🔧 Добавление алиаса в Fish конфигурацию..."
set -l fish_config "$HOME/.config/fish/config.fish"

# Создаем директорию fish config если её нет
mkdir -p (dirname $fish_config)

# Проверяем, есть ли уже алиас
if not grep -q "alias dotfiles" $fish_config
    echo "" >> $fish_config
    echo "# Dotfiles management alias" >> $fish_config
    echo "alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'" >> $fish_config
    echo "✅ Алиас добавлен в $fish_config"
else
    echo "ℹ️  Алиас уже существует в $fish_config"
end

# Инициализируем субмодули если есть
if test -f "$HOME/.gitmodules"
    echo "📦 Инициализация субмодулей..."
    dotfiles submodule init
    dotfiles submodule update
end

echo ""
echo "🎉 Dotfiles успешно установлены!"
echo ""
echo "🔄 Перезапустите Fish shell или выполните:"
echo "   source ~/.config/fish/config.fish"
echo ""
echo "📋 Полезные команды:"
echo "   dotfiles status    - статус репозитория"
echo "   dotfiles add <file> - добавить файл"
echo "   dotfiles commit -m 'message' - закоммитить"
echo "   dotfiles push      - отправить изменения"
echo ""

if test -d $backup_dir
    echo "📦 Бэкап старых файлов: $backup_dir"
end
```

## Вариант 2: Однострочная установка

Добавьте в README вашего репозитория:

```bash
# Быстрая установка (скопируйте и вставьте в терминал)
curl -fLo /tmp/install-dotfiles.fish https://raw.githubusercontent.com/rmuhamedgaliev/dotfiles/master/install.fish && fish /tmp/install-dotfiles.fish
```

## Вариант 3: Bash версия (для совместимости)

Если нужна совместимость с bash/zsh, создайте `install.sh`:

```bash
#!/bin/bash

DOTFILES_REPO="git@github.com:rmuhamedgaliev/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "🐟 Установка dotfiles..."

# Проверяем Git
if ! command -v git >/dev/null 2>&1; then
    echo "❌ Git не установлен"
    exit 1
fi

# Удаляем существующую директорию
if [ -d "$DOTFILES_DIR" ]; then
    echo "🗑️  Удаляем существующую директорию dotfiles..."
    rm -rf "$DOTFILES_DIR"
fi

# Клонируем
echo "📥 Клонирование репозитория..."
git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"

# Создаем функцию dotfiles
function dotfiles {
   /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

# Бэкап конфликтующих файлов
echo "💾 Проверка конфликтов..."
if ! dotfiles checkout 2>/dev/null; then
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    echo "⚠️  Создание бэкапа в $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    dotfiles checkout 2>&1 | egrep "\s+\." | awk '{print $1}' | while IFS= read -r file; do
        if [ -f "$HOME/$file" ]; then
            mkdir -p "$(dirname "$BACKUP_DIR/$file")"
            mv "$HOME/$file" "$BACKUP_DIR/$file"
            echo "  📦 $file -> $BACKUP_DIR/$file"
        fi
    done
    
    dotfiles checkout
fi

# Настройка
dotfiles config --local status.showUntrackedFiles no

# Добавляем алиас
SHELL_RC=""
if [ "$SHELL" = "/bin/fish" ] || [ "$SHELL" = "/usr/bin/fish" ]; then
    SHELL_RC="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$SHELL_RC")"
    ALIAS_LINE="alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'"
elif [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
    ALIAS_LINE="alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'"
else
    SHELL_RC="$HOME/.bashrc"
    ALIAS_LINE="alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'"
fi

if ! grep -q "alias dotfiles" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Dotfiles management alias" >> "$SHELL_RC"
    echo "$ALIAS_LINE" >> "$SHELL_RC"
fi

# Субмодули
if [ -f "$HOME/.gitmodules" ]; then
    echo "📦 Инициализация субмодулей..."
    dotfiles submodule init
    dotfiles submodule update
fi

echo ""
echo "🎉 Dotfiles установлены успешно!"
echo "🔄 Перезапустите shell или выполните: source $SHELL_RC"
```

## Вариант 4: Расширенный скрипт для Fedora/RHEL с DNF

```fish
#!/usr/bin/env fish

# install-fedora.fish - полная установка с зависимостями для Fedora/RHEL

set -l DOTFILES_REPO "git@github.com:rmuhamedgaliev/dotfiles.git"
set -l DOTFILES_DIR "$HOME/.dotfiles"

echo "🚀 Полная установка dotfiles и зависимостей для Fedora/RHEL..."

# Функция для установки пакетов через DNF
function install_packages
    echo "📦 Установка пакетов через DNF..."
    
    # Основные пакеты
    sudo dnf install -y fish vim git curl wget unzip
    
    # Включаем RPM Fusion для дополнительных пакетов
    echo "🔧 Включение RPM Fusion репозиториев..."
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-(rpm -E %fedora).noarch.rpm
    
    # Устанавливаем дополнительные шрифты
    echo "🎨 Установка Nerd Fonts..."
    
    # Создаем директорию для шрифтов
    mkdir -p ~/.local/share/fonts
    
    # Скачиваем и устанавливаем популярные Nerd Fonts
    set -l fonts_dir "/tmp/nerd-fonts"
    mkdir -p $fonts_dir
    
    echo "  📥 Скачиваем JetBrains Mono Nerd Font..."
    curl -fLo "$fonts_dir/JetBrainsMono.zip" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    
    echo "  📥 Скачиваем Hack Nerd Font..."
    curl -fLo "$fonts_dir/Hack.zip" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
    
    echo "  📥 Скачиваем FiraCode Nerd Font..."
    curl -fLo "$fonts_dir/FiraCode.zip" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
    
    # Распаковываем шрифты
    for font_zip in $fonts_dir/*.zip
        echo "  📦 Распаковка "(basename $font_zip)"..."
        unzip -q "$font_zip" -d ~/.local/share/fonts/
    end
    
    # Обновляем кэш шрифтов
    echo "  🔄 Обновление кэша шрифтов..."
    fc-cache -fv
    
    # Очищаем временные файлы
    rm -rf $fonts_dir
    
    echo "✅ Пакеты установлены успешно!"
end

# Проверяем, что мы на Fedora/RHEL системе
if not command -v dnf >/dev/null
    echo "❌ DNF не найден. Этот скрипт предназначен для Fedora/RHEL систем."
    echo "   Для других дистрибутивов используйте базовый install.fish"
    exit 1
end

# Установка зависимостей
install_packages

# Устанавливаем Fish как shell по умолчанию
echo "🐟 Настройка Fish как shell по умолчанию..."
if not grep -q (command -v fish) /etc/shells
    echo (command -v fish) | sudo tee -a /etc/shells
end

# Меняем shell (пользователь сам подтвердит)
echo "🔄 Хотите сделать Fish shell по умолчанию? (y/n)"
read -l response
if test "$response" = "y" -o "$response" = "Y"
    chsh -s (command -v fish)
    echo "✅ Fish установлен как shell по умолчанию"
end

echo ""
echo "📥 Теперь устанавливаем dotfiles..."

# Установка dotfiles (основной код)
if test -d $DOTFILES_DIR
    echo "🗑️  Удаляем существующую директорию dotfiles..."
    rm -rf $DOTFILES_DIR
end

echo "📥 Клонирование dotfiles репозитория..."
git clone --bare $DOTFILES_REPO $DOTFILES_DIR

# Создаем временный алиас
alias dotfiles="/usr/bin/git --git-dir=$DOTFILES_DIR --work-tree=$HOME"

# Создаем бэкап существующих файлов
echo "💾 Создание бэкапа существующих конфигураций..."
set -l backup_dir "$HOME/.config-backup-"(date +%Y%m%d-%H%M%S)

if dotfiles checkout 2>/dev/null
    echo "✅ Checkout выполнен успешно"
else
    echo "⚠️  Найдены конфликтующие файлы, создаем бэкап в $backup_dir"
    mkdir -p $backup_dir
    
    dotfiles checkout 2>&1 | grep -E "^\s+" | awk '{print $1}' | while read -l file
        if test -f "$HOME/$file"
            set -l dir (dirname "$backup_dir/$file")
            mkdir -p $dir
            mv "$HOME/$file" "$backup_dir/$file"
            echo "  📦 $file -> $backup_dir/$file"
        end
    end
    
    dotfiles checkout
end

# Настраиваем git
dotfiles config --local status.showUntrackedFiles no

# Добавляем алиас в Fish конфигурацию
echo "🔧 Добавление алиаса в Fish конфигурацию..."
set -l fish_config "$HOME/.config/fish/config.fish"
mkdir -p (dirname $fish_config)

if not test -f $fish_config
    touch $fish_config
end

if not grep -q "alias dotfiles" $fish_config
    echo "" >> $fish_config
    echo "# Dotfiles management alias" >> $fish_config
    echo "alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'" >> $fish_config
    echo "✅ Алиас добавлен в $fish_config"
end

# Инициализируем субмодули если есть
if test -f "$HOME/.gitmodules"
    echo "📦 Инициализация субмодулей..."
    dotfiles submodule init
    dotfiles submodule update
end

# Устанавливаем дополнительные инструменты
echo "🛠️  Установка дополнительных инструментов..."

# Starship prompt
if not command -v starship >/dev/null
    echo "⭐ Установка Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
end

# Fisher (менеджер плагинов для Fish)
if not test -f ~/.config/fish/functions/fisher.fish
    echo "🎣 Установка Fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
end

echo ""
echo "🎉 Установка завершена!"
echo ""
echo "📋 Что было установлено:"
echo "   • Fish shell, Vim, Git, Curl, Wget"
echo "   • Nerd Fonts (JetBrains Mono, Hack, FiraCode)"
echo "   • Starship prompt"
echo "   • Fisher (менеджер плагинов Fish)"
echo "   • Ваши dotfiles"
echo ""
echo "🔄 Рекомендуется перезапустить терминал или выполнить:"
echo "   exec fish"
echo ""
echo "📋 Полезные команды:"
echo "   dotfiles status         - статус репозитория"
echo "   dotfiles add <file>     - добавить файл"
echo "   dotfiles commit -m 'msg' - закоммитить"
echo "   dotfiles push           - отправить изменения"
echo "   fisher list             - список Fish плагинов"
echo ""

if test -d $backup_dir
    echo "📦 Бэкап старых файлов: $backup_dir"
end

echo "✨ Готово! Добро пожаловать в настроенное окружение!"
```

## Как использовать:

1. **Добавьте скрипт в ваш dotfiles репозиторий**:
```fish
# В корне вашего dotfiles репозитория
dotfiles add install.fish
dotfiles commit -m "Добавлен скрипт автоустановки"
dotfiles push
```

2. **Быстрая установка на новой машине**:
```fish
# Одной командой
curl -fLo /tmp/install.fish https://raw.githubusercontent.com/rmuhamedgaliev/dotfiles/master/install.fish && fish /tmp/install.fish

# Или клонировать и запустить
git clone https://github.com/rmuhamedgaliev/dotfiles.git /tmp/dotfiles-setup
fish /tmp/dotfiles-setup/install.fish
```

3. **Добавьте в README репозитория**:
```markdown
## Быстрая установка

```bash
curl -fLo /tmp/install.fish https://raw.githubusercontent.com/rmuhamedgaliev/dotfiles/master/install.fish && fish /tmp/install.fish
```

Какой вариант вам больше нравится? Могу адаптировать под ваши нужды!
