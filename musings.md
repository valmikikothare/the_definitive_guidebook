# Musings

## Bash

### Reverse search
To search for a command in the history, press `ctrl+r` and then type the command.

To cycle through matches, press `ctrl+r` again.

To use the last argument of the previous command again, press `alt+.`

## Filesystem

### Set ownership
To set ownership of a file or directory to the current user:

```bash
sudo chown -R $USER:$USER <file-or-directory>
```

### Set permissions
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

### Disk usage
To check disk usage by filesystem, use 
```bash
df -h
```
where `h` stands for human readable.

To check disk usage by directory, use
```bash
du -sh *
```
where `s` stands for summary and `*` stands for all files and directories.

## Git

### Stage file or directory modifications/additions
```bash
git add <file-or-directory>
```

### Stage all modifications/additions
```bash
git add .
```

### Stage all changes (including deletions)
```bash
git add -A
```

### Stage all files for removal
```bash
git rm -r --cached .
```
Useful for removing deleted or ignored files from the index. Typically followed
by:
```bash
git add .
```
to re-stage any unstaged files.

### Unstage files
```bash
git restore --staged .
```
Useful for removing staged files that you've accidentally added or recently
ignored (can be followed by `git add .` to re-stage the files you want to
keep).

**Note:** This will not remove already committed files from the index. Use
`git rm` to remove committed files.

### Uncommit last commit
```bash
git reset --soft "HEAD~1"
```
### Add submodules
```bash
git submodule add <repository> <path>
```

### Update submodules
```bash
git submodule update --init --recursive
```

### Install pre-commit hooks
```bash
pip install pre-commit
pre-commit install
```

### Run pre-commit hooks
```bash
pre-commit run --all-files
```