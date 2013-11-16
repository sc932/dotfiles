# (C) 2013 Scott Clark
# Makefile for my dotfiles
# 
# To set up a new environment
# $ make install
#
# To clean up an environment
# $ make clean

install: ipython vim bash git tmux

clean:
	# ipython
	rm -rf ~/.ipython
	# vim
	rm -rf ~/.vim
	rm ~/.vimrc
	# bash
	rm ~/.bashrc
	# git
	rm ~/.gitconfig
	# tmux
	rm ~/.tmux.conf

ipython:
	cp -r .ipython ~/.ipython

vim:
	cp -r .vim ~/.vim
	ln -s ~/.vim/.vimrc ~/.vimrc

bash:
	cp .bashrc ~/.bashrc
	cp .inputrc ~/.inputrc

# WARNING SET EMAIL/NAME INSIDE
git:
	cp .gitconfig ~/.gitconfig

tmux:
	cp .tmux.conf ~/.tmux.conf
