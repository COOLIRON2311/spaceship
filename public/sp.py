import argparse
import http.client
import tarfile
import urllib.parse
from io import BytesIO
from os import remove, rename
from os.path import exists, realpath, relpath


class Util:
    SERVER = '127.0.0.1:3000'
    # TOKEN = 'TOKEN GOES HERE'
    TOKEN = 'cc03e747a6afbbcbf8be7668acfebee5'

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


def main() -> None:

    parser = argparse.ArgumentParser(description='Online CUDA compiler proxy', epilog='''You must also provide a Makefile that compiles and executes your program like this:
    all:
        gcc test.c -o test
        ./test
    ''', formatter_class=argparse.RawTextHelpFormatter)
    subparser = parser.add_subparsers(dest='command')
    auth_p = subparser.add_parser('auth', help='Authenticate access token')
    init_p = subparser.add_parser('i', help='Initialise current task')
    post_p = subparser.add_parser(
        's', help='Send current task for compilation')
    subparser.add_parser('r', help='Get last posted task result')

    auth_p.add_argument('token', type=str)
    init_p.add_argument('name', type=str)
    post_p.add_argument('files', nargs='+', type=Util.path)
    args = parser.parse_args()

    if args.command == 'auth':
        Util.authenticate(args.token)

    elif args.command == 'i':
        Util.initialize(args.name)

    elif args.command == 's':
        Util.create(args.files)

    elif args.command == 'r':
        Util.result()

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
