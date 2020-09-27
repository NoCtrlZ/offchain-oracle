import net from 'net';
import Request from './request';
import Response from './response';

export default class Client {
    host: string;
    port: number;
    charSet: string;

    constructor(host: string, port: number, charSet = 'utf8') {
        this.host = host;
        this.port = port;
        this.charSet = charSet;
    }

    get = (path: string): Promise<Response> =>
        new Promise((resolve) => {
            const socket = newSocket();
            const request = new Request(path, 'GET');
            const content = `${request.getPrefix()}${request.getOrigin()}${request.getContentType()}\r\n`;
            socket.connect(this.port, this.host, () => socket.write(content));
            socket.on('data', (data: any) => {
                socket.destroy();
                resolve(new Response(data.toString()));
            });
        });

    post = (path: string, body: object): Promise<Response> =>
        new Promise((resolve) => {
            const socket = newSocket();
            const request = new Request(path, 'POST');
            const bodyData = JSON.stringify(body);
            const content = `${request.getPrefix()}${request.getOrigin()}${request.getContentType()}\r\n${bodyData}`;
            socket.connect(this.port, this.host, () => socket.write(content));
            socket.on('data', (data: any) => {
                socket.destroy();
                resolve(new Response(data.toString()));
            });
        });
}

const newSocket = () => new net.Socket();
