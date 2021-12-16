import argparse
import http.client
import tarfile
import urllib.parse
from io import BytesIO, TextIOWrapper
from os.path import exists


class Util:
    SERVER = '127.0.0.1:3000'
    TOKEN = 'cc03e747a6afbbcbf8be7668acfebee5'

    @staticmethod
    def __get_task() -> str:
        if exists('.task'):
            with open('.task', 'r') as f:
                return f.read()
        else:
            raise LookupError

    @staticmethod
    def initialize(name: str) -> None:
        with open('.task', 'w') as f:
            f.write(name)

    @staticmethod
    def result() -> None:
        try:
            name = Util.__get_task()
            con = http.client.HTTPConnection(Util.SERVER)
            con.request('GET', '/task/result',
                        urllib.parse.urlencode({'token': Util.TOKEN, 'name': name}))
            print(con.getresponse().read().decode('utf8'))
            con.close()
        except LookupError:
            print('You have no active tasks')

    @staticmethod
    def post(files: list[TextIOWrapper]) -> None:
        try:
            name = Util.__get_task()
            data = BytesIO()
            with tarfile.open(fileobj=data, mode='w') as tar:
                for f in files:
                    tar.add(f.name)
            con = http.client.HTTPConnection(Util.SERVER)
            con.request('POST', '/task/post',
                        urllib.parse.urlencode({'token': Util.TOKEN, 'name': name, 'tar': data.getvalue()}))
            print(con.getresponse().read().decode('utf8'))
            con.close()

        except LookupError:
            print('You have no active tasks')


def main() -> None:

    parser = argparse.ArgumentParser(description='Online CUDA compiler proxy')
    subparser = parser.add_subparsers(dest='command')
    select_p = subparser.add_parser('init', help='Initialise current task')
    post_p = subparser.add_parser(
        'post', help='Send current task for comiplation')
    subparser.add_parser('result', help='Get last posted task result')

    select_p.add_argument('name', type=str)
    post_p.add_argument('files', nargs='+', type=argparse.FileType('r'))
    args = parser.parse_args()

    if args.command == 'init':
        Util.initialize(args.name)

    elif args.command == 'post':
        Util.post(args.files)

    else:
        Util.result()


if __name__ == '__main__':
    main()
