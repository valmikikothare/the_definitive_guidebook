# Useful Things

## Bash

### Reverse Search
    To search for a command in the history, press `ctrl+r` and then type the command.

    To cycle through matches, press `ctrl+r` again.

    To use the last argument of the previous command again, press `alt+.`

### Set Ownership
    To set ownership of a file or directory to the current user:

    ```bash
    sudo chown -R $USER:$USER <file-or-directory>
    ```

### Set Permissions
    To set permissions of a file or directory to the current user:

    ```bash
    sudo chmod -R <permissions> <file-or-directory>
    ```
    Common permissions:
    - 400	r--------	Readable by owner only
    - 500	r-x------	Avoid Changing
    - 600	rw-------	Changeable by user
    - 644	rw-r--r--	Read and change by user
    - 660	rw-rw----	Changeable by user and group
    - 700	rwx------	Only user has full access
    - 755	rwxr-xr-x	Only changeable by user
    - 775	rwxrwxr-x	Sharing mode for a group
    - 777	rwxrwxrwx	Everybody can do everything
    - +rwx	            Add read/write/execute permission, respectively
    - -rwx	            Remove read/write/execute permission, respectively
    
    
    
