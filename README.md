# Script para trabajar con `dotfiles`

Script para importar y restaurar dotfiles. Los `dotfiles` son configuraciones de archivo o carpetas que comiezan con punto `(.)`, como por ejemplo `.bashrc|.icons|.config`. Aunque tambien puedes importar cualquier tipo de archivo o carpeta.

## Instalación

```bash
sudo wget -c "https://github.com/roilanbr/mydotfile/raw/refs/heads/main/mydotfiles.sh" -O "/usr/bin/mydotfile"
sudo chmod +x "/usr/bin/mydotfiles"
```

Al ejecutar por primera vez creara la carpeta `~/.midotfile` que a su vez contendra:

* `backup/` Carpeta con los dotfiles importados
* `db_dotfiles` Base de datos con los dotfiles importados
* `list_dotfiles` Una lista con los dotfiles a importar


## Uso

Sintaxis básica:

```bash
mydotfiles -i <dotfile_a_importar>
```

### Parametros

* `-d, --delete`  Remover dotfiles importado
* `-c, --check <dotfiles|database>`   Comprueba dotfiles o database
  * `dotfiles`    Comprueba que los dotfiles importados se encuentre en la DB (`db_dotfiles`), si no se encuentra los elimina de `backup/`.
  * `database`    Comprueba que los registros DB (`db_dotfiles`) concuerde con los dotfiles, si no se encuentra los elimina de la db.
* `-f, --file <file_list>`    Importa dotfiles desde una lista con la ruta a los dotfiles, si no se espesifica se usa la lista: `$HOME/.mydotfiles/list_dotfiles`
* `-h, --help`    Ver esta ayuda y salir
* `-i, --import <path_to_dotfiles>`  Importar dotfiles
* `-l, --list`    Listar dotfiles
* `-r, --restore` Restaurar dotfiles, si el destino no se espesifica se restaura en la ruta por defecto que se encuentra en el registro de la base de datos.
