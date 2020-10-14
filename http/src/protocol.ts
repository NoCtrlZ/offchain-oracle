export const Ctype = {
    Plain: 1,
    Html: 2,
    Json: 3,
    Other: 4
};

export const checkCtype = (ctype: string): number => {
    switch (true) {
        case ctype.startsWith('text/plain'):
            return Ctype.Plain;
        case ctype.startsWith('text/html'):
            return Ctype.Html;
        case ctype.startsWith('application/json'):
            return Ctype.Json;
        default:
            return Ctype.Other;
    }
};

export const getBodyFromRes = (type: number, body: string): object | string => {
    switch (type) {
        case Ctype.Json:
            return JSON.parse(body);
        case Ctype.Plain:
        case Ctype.Html:
        case Ctype.Other:
        default:
            return body;
    }
};
