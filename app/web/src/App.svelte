<script lang="ts">
    import { onMount } from "svelte";
    import { ColorScheme } from "./ui/model/ColorScheme";
    import ClientState from "./ui/state/ClientState";
    import RouteState from "./ui/state/RouteState";
    import LandingPage from "./ui/pages/LandingPage.svelte";
    import InnerRoute from "./ui/pages/InnerRoute.svelte";
    import SecondPage from "./ui/pages/SecondPage.svelte";
    import Page404 from "./ui/pages/Page404.svelte";
    import GoogleAuthDs from "./data/GoogleAuthDs";
    import AuthenticationState from "./ui/state/AuthenticationState";

    let isDarkMode = false;
    function updateIsDarkMode() {
        isDarkMode = ClientState.colorScheme == ColorScheme.Dark;
    }
    ClientState.subscribe(updateIsDarkMode);

    let page: any;
    function updatePage() {
        const segments = RouteState.directory("/");

        page = (() => {
            if (segments.length == 0) return LandingPage;

            switch (segments[0]) {
                case "inner":
                    return InnerRoute;
                case "second":
                    return SecondPage;
                default:
                    return Page404;
            }
        })();
    }
    RouteState.subscribe(updatePage);

    onMount(() => {
        updateIsDarkMode();
        updatePage();
    });
</script>

<main class="{isDarkMode ? 'dark' : 'light'} text-black dark:text-white">
    <svelte:component this={page} />
</main>
