<script lang="ts">
    import { type Icon } from "../model/Icon";
    import LoadingIndicator from "./LoadingIndicator.svelte";

    export let icon: Icon | null;
    export let label: string;
    export let color: string;
    export let outlined: boolean = false;
    export let loading: boolean = false;
    export let action: () => void = () => {};

    function foregroundColor(): string {
        if (outlined) return color;
        else return color == "white" ? "black" : "white";
    }
</script>

<button
    on:click={action}
    style="border-color: {outlined ? foregroundColor() : color}; {!outlined
        ? `background-color: ${color};`
        : ''}"
    class="rounded-3xl border h-[50px] w-full px-5 row space-x-1.5 flex items-center justify-center"
>
    {#if loading}
        <LoadingIndicator size={26} lineWidth={4} color={foregroundColor()} />
    {:else if icon != null}
        <div class="size-[18px]">
            <svelte:component
                this={icon}
                color={!outlined ? null : foregroundColor()}
            />
        </div>
        <p class="font-semibold" style="color: {foregroundColor()};">{label}</p>
    {/if}
</button>
