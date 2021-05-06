# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: widraugr <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2018/11/29 13:07:44 by widraugr          #+#    #+#              #
#    Updated: 2021/05/06 16:14:48 by mixfon           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = puzzle

FILE_SWIFT = main.swift\
			 Board.swift\
			 Exception.swift\
			 Heap.swift\
			 Heuristic.swift\
			 Puzzle.swift

all : $(NAME)

$(NAME): $(FILE_SWIFT)
	swiftc $(FILE_SWIFT) -o $(NAME)

clean:
	/bin/rm -f $(NAME)
	
re: clean all 

