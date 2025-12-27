# Script para trabajar con `dotfiles`

Script para importar y restaurar dotfiles

## Instalación

```bash
sudo wget -c "https://github.com/roilanbr/mydotfile/raw/refs/heads/main/mydotfile.sh" -O "/usr/bin/mydotfile"

sudo chmod +x "/usr/bin/mydotfile"
```

Al ejecutar por primera vez creara la carpeta `~/.midotfile` que a su vez contendra:

* `backup/` Carpeta con los dotfiles importados
* `db_dotfiles` Base de datos con los dotfiles importados
* `list_dotfiles` Una lista con los dotfiles a importar

## Parametros

* `-d, --delete`  Remove dotfiles
* `-c, --check`   'dotfiles' or 'database' is passed depending on what  you  want to check.
* `-f, --file`    Import from list in a file, if not specified it will be used: `/home/user/.mydotfiles/list_dotfile`
* `-h, --help`    Display this help and exit
* `-i, --import`  Import dotfiles
* `-l, --list`    List dotfiles
* `-r, --restore` Restore dotfiles, if the destination path is not specified, it is restored to the default path of dotfiles
```