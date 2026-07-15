# (C) 2013 Scott Clark
# Makefile for my dotfiles
#
# To set up a new environment
# $ make install
#
# To clean up an environment
# $ make clean

install: ipython vim bash git tmux terminal-logging tmux-rig

# targets are actions, not files — without .PHONY the terminal-logging DIRECTORY
# shadowed its target ("up to date" no-op; make install silently skipped it, caught 2026-07-15)
.PHONY: install clean ipython vim bash git tmux terminal-logging tmux-rig

clean:
	# ipython
	rm -rf ~/.ipython
	# vim
	rm -rf ~/.vim
	rm ~/.vimrc
	# bash
	rm ~/.bashrc
	rm ~/.bash_profile
	# git
	rm ~/.gitconfig
	# tmux
	rm ~/.tmux.conf
	# terminal-logging
	-systemctl --user disable --now terminal-logs-rotate.timer 2>/dev/null
	rm -f ~/.config/terminal-logging.zsh ~/.config/tmux-log.sh ~/.local/bin/tlog-rotate
	rm -f ~/.config/systemd/user/terminal-logs-rotate.service ~/.config/systemd/user/terminal-logs-rotate.timer
	rm -f ~/.local/share/konsole/Scott.profile
	# tmux-rig (standing sessions + reaper watchdog)
	-systemctl --user disable --now tmux-reaper.timer 2>/dev/null
	-systemctl --user disable --now tmux-rig.service 2>/dev/null
	rm -f ~/.local/bin/rig ~/.local/bin/tmux-reaper
	rm -f ~/.config/systemd/user/tmux-rig.service
	rm -f ~/.config/systemd/user/tmux-reaper.service ~/.config/systemd/user/tmux-reaper.timer

ipython:
	cp -r .ipython ~/.ipython

vim:
	cp -r .vim ~/.vim
	ln -s ~/.vim/.vimrc ~/.vimrc

bash:
	cp .bashrc ~/.bashrc
	cp .bash_profile ~/.bash_profile
	cp .inputrc ~/.inputrc

# WARNING SET EMAIL/NAME INSIDE
git:
	cp .gitconfig ~/.gitconfig

tmux:
	cp .tmux.conf ~/.tmux.conf

terminal-logging:
	bash terminal-logging/install.sh

tmux-rig:
	bash tmux-rig/install.sh
