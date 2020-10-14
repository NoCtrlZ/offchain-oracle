import { HTTP_VERSION, DEFAULT_ORIGIN, DEFAULT_CONTENT_TYPE } from './global';

export default class Request {
    path: string;
    method: string;
    httpVersion: string;
    origin: string;
    contentType: string;

    constructor(
        path: string,
        method: string,
        contentType = DEFAULT_CONTENT_TYPE
    ) {
        this.path = path;
        this.method = method;
        this.httpVersion = HTTP_VERSION;
        this.origin = DEFAULT_ORIGIN;
        this.contentType = contentType;
    }

    getPrefix = (): string =>
        `${this.method} ${this.path} ${this.httpVersion}\r\n`;

    getOrigin = (): string => `Host: ${this.origin}\r\n`;

    getContentType = (): string => `Content-Type: ${this.contentType}\r\n`;
}
