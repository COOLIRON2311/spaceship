import argparse
import http.client
import tarfile

import urllib.parse
from io import BytesIO
from os import remove, rename
from os.path import exists, realpath, relpath

import tkinter as tk
import tkinter.ttk as ttk
import pandas as pd
from matplotlib import pyplot as plt


class StatPlotter(tk.Tk):
    INDEX = 'Date'
    headers: list[str]
    df: pd.DataFrame
    app: ttk.Frame
    options: ttk.LabelFrame
    buttons: ttk.Frame
    ok: ttk.Button
    cancel: ttk.Button
    checks: list[ttk.Checkbutton]

    def __init__(self, file: str) -> None:
        if not file.endswith('.csv'):
            raise Exception('Not a csv file')
        super().__init__()
        self.df = pd.read_csv(file)
        self.headers = list(self.df)
        self.app = ttk.Frame(self, padding=(5, 2))
        self.options = ttk.LabelFrame(self.app, text='Select columns',
                                      borderwidth=10)
        self.buttons = ttk.Frame(self.app,
                                 borderwidth=2, padding=(5, 2))
        self.ok = ttk.Button(self.buttons, text='OK',
                             command=self.__plot)
        self.cancel = ttk.Button(self.buttons, text='Cancel',
                                 command=self.destroy)
        self.checks = [ttk.Checkbutton(self.options, text=i, onvalue=True, offvalue=False)
                       for i in self.headers if i != self.INDEX]

        self.minsize(230, 150)
        self.title('spaceship')
        self.resizable(False, False)
        self.app.pack(fill='both')
        self.options.pack(side='top', fill='both')

        for i in self.checks:
            i.state(['selected'])
            i.pack(anchor='w')

        self.buttons.pack(side='bottom')
        self.ok.pack(side='left')
        self.cancel.pack(side='right')
        self.__center()

    def __plot(self) -> None:
        self.df[[self.INDEX, *(h for c, h in zip(self.checks,
                               self.headers) if c.state())]].plot(self.INDEX)
        # self.destroy()
        plt.show()

    def __center(self, geometry: str = '') -> None:
        if geometry:
            ww, wh, = map(int, geometry.split('x'))
        else:
            ww = self.winfo_reqwidth()
            wh = self.winfo_reqheight()
            x = self.winfo_screenwidth() // 2 - ww // 2
            y = self.winfo_screenheight() // 2 - wh // 2
        if geometry:
            self.geometry('{}x{}+{}+{}'.format(ww, wh, x, y))
        else:
            self.geometry('+{}+{}'.format(x, y))


class Util:
    SERVER = '127.0.0.1:3000'
    TOKEN = 'TOKEN GOES HERE'

    @staticmethod
    def path(path: str) -> str:
        if exists(path):
            return path
        raise argparse.ArgumentTypeError(f'{path} is not a valid path')

    @staticmethod
    def __get_task() -> str:
        if exists('.task'):
            with open('.task', 'r') as f:
                return f.read()
        else:
            raise LookupError

    @staticmethod
    def authenticate(token: str) -> None:
        path = realpath(__file__)
        with open(path, 'r') as r, open(path+'.tmp', 'w') as w:
            w.write(r.read().replace('TOKEN GOES HERE', token))
        remove(path)
        rename(path+'.tmp', path)

    @staticmethod
    def initialize(name: str) -> None:
        with open('.task', 'w') as f:
            f.write(name)
        print(f'Task {name} initialised')

    @staticmethod
    def result() -> None:
        try:
            name = Util.__get_task()
            con = http.client.HTTPConnection(Util.SERVER)
            con.request('POST', '/task/result',
                        urllib.parse.urlencode({'token': Util.TOKEN, 'name': name}))
            print(con.getresponse().read().decode('utf8'))
            con.close()
        except LookupError:
            print('You have no active tasks')

    @staticmethod
    def create(files: list[str]) -> None:
        files = [relpath(i) for i in files]

        if 'Makefile' not in files:
            print('You must provide a top-level Makefile')
            return

        try:
            name = Util.__get_task()
            data = BytesIO()
            with tarfile.open(fileobj=data, mode='w') as tar:
                for f in files:
                    tar.add(f)

            con = http.client.HTTPConnection(Util.SERVER)
            con.request('POST', '/task/create',
                        urllib.parse.urlencode({'token': Util.TOKEN, 'name': name, 'tar': data.getvalue()}))
            print(con.getresponse().read().decode('utf8'))
            con.close()

        except LookupError:
            print('You have no active tasks')

    @staticmethod
    def statistics() -> None:
        try:
            name = Util.__get_task()
            con = http.client.HTTPConnection(Util.SERVER)
            con.request('POST', '/stats',
                        urllib.parse.urlencode({'token': Util.TOKEN, 'name': name}))
            stats = con.getresponse().read().decode('utf8')
            con.close()
            with open(f'{name}.csv', 'w') as f:
                f.write(stats)
            print(f'Downloaded statistics for {name}')
        except LookupError:
            print('You have no active tasks')

    @staticmethod
    def plot(file: str) -> None:
        StatPlotter(file).mainloop()

def main() -> None:

    parser = argparse.ArgumentParser(description='Online CUDA compiler proxy', epilog='''You must also provide a Makefile that compiles and executes your program like this:
    all:
        gcc test.c -o test
        ./test
    ''', formatter_class=argparse.RawTextHelpFormatter)
    subparser = parser.add_subparsers(dest='command')
    auth_p = subparser.add_parser('auth', help='Authenticate access token')
    init_p = subparser.add_parser('init', help='Initialise current task')
    post_p = subparser.add_parser(
        'send', help='Send current task for compilation')
    subparser.add_parser('res', help='Get last posted task result')
    subparser.add_parser('stat', help='Download run statistics of active task')
    stat_p = subparser.add_parser('plot', help='Visualize run statistics stored in a csv file')

    auth_p.add_argument('token', type=str)
    init_p.add_argument('name', type=str)
    post_p.add_argument('files', nargs='+', type=Util.path)
    stat_p.add_argument('file', nargs=1, type=Util.path)
    args = parser.parse_args()

    if args.command == 'auth':
        Util.authenticate(args.token)

    elif args.command == 'init':
        Util.initialize(args.name)

    elif args.command == 'send':
        Util.create(args.files)

    elif args.command == 'res':
        Util.result()

    elif args.command == 'stat':
        Util.statistics()

    elif args.command == 'plot':
        Util.plot(args.file[0])

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
