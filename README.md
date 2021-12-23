# Spaceship

Spaceship is an online compiler proxy that allows users to run CUDA programs without the need to have an nvidia gpu.

### Common usage scenario:
```
./sp.py i test
(Initialize 'test' task)

./sp.py s Makefile test.c
(Send 'test.c' and the Makefile for building and running it to the server)

./sp.py r
(See the results of task compilation and execution)

```

### Requirements:
Client:
```
python
```

Server:
```
ruby 2.7.5
rails 6.1.4
postgresql and pg gem
```

To setup a spaceship server you will need to change the domain in `config/application.rb` and `Util.SERVER` variable in `public/sp.py`

