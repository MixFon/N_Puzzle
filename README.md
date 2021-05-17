# N_Puzzle
Цель этого проекта в нахождении решения для N-Puzzle с помощью алгоритма A*.

В проекте представлены 2 ветки:

**master** - консольная версия приложения. Программа решает головоломки 3x3, 4x4, 5x5 в течение нескольких секунд, головоломки 6x6 и выше в течение нескольких минут.

**UIN_Pazzle** - оконная версия программы. Данная программа реализована в виде игры, в которой можно самостоятельно собирать головоломку. Так же программа решает головоломки 3x3 и 4x4. Данные ограничения связаны с тем, что удалось найти картинки-числа только от 1 до 16, распространяемые по бесплатной лицензии.

## Использование
### master
Для работы с программой необходимо:
1. Клонировать ветку master
2. Перейти в папку с исходниками
3. Собрать проект (make)
4. Сгенерировать головоломку нужного размера:
    * C помощью генератора головоломок (npuzzle-gen.py).
    * Самостоятельно вписывать головоломку руками при запуске программы (./puzzle) в поток ввода.
    * Cохранить головоломку в файл и передавать имя файла в качестве аргумента при запуске программы.
---
    
    git clone https://github.com/MixFon/N_Puzzle.git
    cd N_Puzzle/N_Puzzle
    make
    python2.7 npuzzle-gen.py -s 4               # Генерирование головоломки 4x4
    
    python2.7 npuzzle-gen.py -s 5 > file_name   # Генерирование головоломки 5x5 и сохране ее в файл file_name
    ./puzzle file_name                          # Чтение головоломки из файла file_name
    
    python2.7 npuzzle-gen.py -s 3 | ./puzzle -m # Герерирование головоломки 3x3 и передача на поток ввода ./puzzle


### UIN_Pazzle
Для работы в оконном режиме необходима среда разработки XCode.
1. Клонировать ветку master
2. Перейти в папку с проектом
3. Переключиться в ветку UIN_Pazzle
4. Запустить проект с помощью XCode
5. Собрать проект
---

    git clone https://github.com/MixFon/N_Puzzle.git
    cd N_Puzzle
    git checkout UIN_Pazzle
    open UIN_Pazzle.xcodeproj
    
    
**Генерирование случайной головоломки 4x4 и ее решение:**
![exemple one](https://github.com/MixFon/N_Puzzle/blob/master/images/Screen_Recording_2021-05-17_at_13.41.01.gif)

**Генерирование головоломки 3x3 и его решение (жадный алгоритм)**
![exemple two](https://github.com/MixFon/N_Puzzle/blob/master/images/Screen_Recording_2021-05-17_at_13.46.00.gif)

**Своболная игра и поиск решения**
![exemple three](https://github.com/MixFon/N_Puzzle/blob/master/images/Screen_Recording_2021-05-17_at_13.50.14.gif)


## Поиск решения. Алгоритм А*

Для поиска решения применяется алгоритм А*. По ходу работы алгоритма строится взвешенный граф, в корне которого находится стартовое поле, а вершинами являются поля с возможными комбинациями ходом от родительского. Для каждой вершины вычисляется стоимость перехода (вес) по следующей формуле:

<a href="https://www.codecogs.com/eqnedit.php?latex=\dpi{120}&space;\large&space;f(\nu&space;)=g(\nu&space;)&space;&plus;&space;h(\nu)" target="_blank"><img src="https://latex.codecogs.com/png.latex?\dpi{120}&space;\large&space;f(\nu&space;)=g(\nu&space;)&space;&plus;&space;h(\nu)" title="\large f(\nu )=g(\nu ) + h(\nu)" /></a>

g(v) - количество перестановок, сделанных от стартовой вершины. (используется для жадного алгоритма)
h(v) - эвристическая оценка стоимости пути. Эвристика.
Для вычисления эвристики используются следующие функции:

**Манхэттенское расстояние** 
![exemple manhetten](https://github.com/MixFon/N_Puzzle/blob/master/images/fkY5DZL0.png)

**Расстояние Чебышева** 
![exemple cheb](https://github.com/MixFon/N_Puzzle/blob/master/images/xJmGyaY8.png)

**Евклидово расстояние** 
![exemple Euckl](https://github.com/MixFon/N_Puzzle/blob/master/images/7zlYJYzs.png)
