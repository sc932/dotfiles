# (C) 2013 Scott Clark
# Makefile for my dotfiles
#
# To set up a new environment
# $ make install
#
# To clean up an environment
# $ make clean

install: ipython vim bash git tmux terminal-logging

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
