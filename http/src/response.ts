import { checkCtype, getBodyFromRes } from './protocol';

export default class Response {
    status: boolean;
    data: object | string;

    constructor(resData: string) {
        const components = resData.split('\r\n\r\n');
        const headers = components[0].split('\r\n');
        const prefixes = headers[0].split(' ');
        this.status = prefixes[1] === '200';
        this.data = rawDataToBody(components, headers);
    }
}

const rawDataToBody = (
    components: string[],
    headers: string[]
): object | string => {
    if (components.length > 1) {
        for (const header of headers)
            if (header.startsWith('Content-Type')) {
                const ctype = header.split(' ');
                const type = checkCtype(ctype[1]);
                return getBodyFromRes(type, components[1]);
            }
        return '';
    } else return '';
};
