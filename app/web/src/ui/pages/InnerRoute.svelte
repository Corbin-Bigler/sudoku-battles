<script lang="ts">
    import { onMount } from "svelte";
    import RouteState from "../state/RouteState";
    import ChildPage from "./inner/ChildPage.svelte";
    import InnerPage from "./InnerPage.svelte";
    import Page404 from "./Page404.svelte";

    let page: any;

    function updatePage() {
        console.log("updatePage");
        const segments = RouteState.directory("inner");
        page = (() => {
            console.log(segments);
            if (segments.length == 0) return InnerPage;

            switch (segments[0]) {
                case "child":
                    return ChildPage;
                default:
                    return Page404;
            }
        })();
    }

    onMount(() => {
        updatePage();
    });
    RouteState.subscribe(updatePage);
</script>

<svelte:component this={page} />
