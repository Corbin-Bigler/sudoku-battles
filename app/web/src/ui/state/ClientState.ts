import { derived, get, writable } from 'svelte/store';
import { ColorScheme } from '../model/ColorScheme';
import LocalStorageDs from '../../data/LocalStorageDs';

const COLOR_SCHEME_KEY = "color-scheme";
const osColorScheme = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? ColorScheme.Dark : ColorScheme.Light;
const initialDarkModeValue = LocalStorageDs.getDarkMode()
const initialColorScheme = initialDarkModeValue == null ? null : initialDarkModeValue ? ColorScheme.Dark : ColorScheme.Light

export default class ClientState {
    private static _colorScheme = writable(initialColorScheme == null ? osColorScheme : initialColorScheme)
    static get colorScheme(): ColorScheme { return get(this._colorScheme) }
    static set colorScheme(colorScheme: ColorScheme) { this._colorScheme.set(colorScheme) }
    static get isDarkMode(): boolean { return this.colorScheme == ColorScheme.Dark }

    static storeColorScheme(colorScheme: ColorScheme) {
        LocalStorageDs.saveDarkMode(colorScheme == ColorScheme.Dark)
        this.colorScheme = colorScheme
    }

    private static state = derived(this._colorScheme, ($_colorScheme, set) => { set({ colorScheme: $_colorScheme, isDarkMode: $_colorScheme == ColorScheme.Dark }); }, { colorScheme: this.colorScheme, isDarkMode: this.isDarkMode });
    static subscribe = this.state.subscribe
}

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
    if (LocalStorageDs.getDarkMode() == null) {
        const newColorScheme = e.matches ? ColorScheme.Dark : ColorScheme.Light;
        ClientState.colorScheme = newColorScheme
    }
});

