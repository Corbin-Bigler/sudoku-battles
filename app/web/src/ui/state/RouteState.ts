import { get, writable } from 'svelte/store';

export default class RouteState {
    private static _url = writable(new URL(window.location.href))
    static get url(): URL { return get(this._url) }
    static set url(newUrl: URL) { this._url.set(newUrl) }

    static directory(root: string): string[] {
        const rootIndex = RouteState.url.pathname.indexOf(root);
        if(rootIndex == -1) return []

        return RouteState.url.pathname
            .slice(rootIndex + root.length)
            .split("/")
            .filter((segment) => segment !== "")
    }

    static navigate(path: string) {
        const newUrl = new URL(path, window.location.origin)
        window.history.pushState({}, "", newUrl.href);
        this.url = newUrl
    }

    static subscribe = (callback: (url: URL) => void) => {this._url.subscribe(callback)};
    static update() {
        this._url.set(new URL(window.location.href))
    }
}

window.addEventListener('popstate', () => { RouteState.update() });