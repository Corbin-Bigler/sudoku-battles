<script lang="ts">
    import FunctionsDs from "../../data/FunctionsDs";
    import GoogleAuthDs from "../../data/GoogleAuthDs";
    import { AppError } from "../../data/Model/AppError";
    import { SetUsernameStatus } from "../../data/Model/SetUsernameStatus";
    import enumCast from "../../utility/EnumCast";
    import RoundedButton from "../components/RoundedButton.svelte";
    import AppleLogo from "../components/icons/AppleLogo.svelte";
    import GoogleLogo from "../components/icons/GoogleLogo.svelte";
    import type AppUser from "../model/AppUser";
    import AuthenticationState from "../state/AuthenticationState";
    import ClientState from "../state/ClientState";

    let showEnterUsername = false;
    let settingUsername = false;
    let authenticating = false;
    let username = "";
    let status: SetUsernameStatus | null = null;
    let error: AppError | null = null;

    async function submitUsername(user: AppUser) {
        settingUsername = true;
        try {
            const response = await FunctionsDs.setUsername(username);
            await AuthenticationState.logInAppUser(user);
            if (response.status != SetUsernameStatus.Success) {
                status = response.status;
            }
        } catch (e) {
            console.error(e);
            const appError = enumCast(AppError, e);
            if (appError != null) {
                error = appError;
            } else {
                error = AppError.Unknown;
            }
        }
    }

    async function onClickGoogle() {
        await GoogleAuthDs.requestRedirect()
    }
</script>

<div
    class="w-screen h-screen bg-blue-400 dark:bg-gray-900 relative overflow-x-hidden"
>
    <div class="absolute left-0 top-0 size-full square-background overflow-hidden">
        <div
            class="size-full {$ClientState.isDarkMode
                ? 'dark-gradient-background'
                : 'gradient-background'}"
        >
            <img
                src="/blurred-highlight.png"
                alt=""
                srcset=""
                class="blur absolute select-none pointer-events-none z-0 {$ClientState.isDarkMode
                    ? 'blue-blur'
                    : ''}"
                style="left: 0px; top: 0px; transform: translate(-50%, -35%);"
            />
            <img
                src="/blurred-highlight.png"
                alt=""
                srcset=""
                class="overflow-hidden blur absolute select-none pointer-events-none z-0 {$ClientState.isDarkMode
                    ? 'blue-blur'
                    : ''}"
                style="right: 0px; bottom: 0px; transform: translate(40%, 35%);"
            />
        </div>
    </div>

    <div
        class="absolute left-0 top-0 z-10 size-full column items-center justify-between max-h-[800px]"
    >
        <img
            src="/drawing-hand.svg"
            alt=""
            class="w-full max-w-xl max-h-xl pointer-events-none px-4 pt-10"
        />

        <div class="column max-w-[600px] px-4 pb-4">
            {#if $AuthenticationState.user != null && showEnterUsername}
                <div>username</div>
            {:else}
                <p class="text-2xl pb-4 font-semibold">
                    Ready to Start Battling?
                </p>
                <p class=" pb-7">
                    Sudoku Battles lets you put your wits to the test against
                    your friends. It’s not just about getting the right
                    answer—it’s about being faster and smarter than your
                    opponent
                </p>
                <div
                    class="bg-gradient-to-r from-transparent via-white to-transparent h-[1px] w-full"
                ></div>
                <p class="pt-7 pb-4 text-2xl">Continue with</p>

                <div class="row space-x-4">
                    <RoundedButton
                        icon={GoogleLogo}
                        label="Google"
                        color="white"
                        outlined={false}
                        action={onClickGoogle}
                    />
                    <RoundedButton
                        icon={AppleLogo}
                        label="Apple"
                        color="white"
                        outlined={false}
                    />
                </div>
            {/if}
        </div>
    </div>
</div>

<style>
    .blur {
        max-width: 100%;
        max-height: 100%;
        width: auto;
        height: auto;
    }
    .blue-blur {
        filter: brightness(0) saturate(100%) invert(61%) sepia(30%)
            saturate(1234%) hue-rotate(190deg) brightness(93%) contrast(92%);
    }
    .square-background {
        background-image: url("square-noise.svg");
        background-size: cover;
    }
    .gradient-background {
        background: linear-gradient(
            180deg,
            color-mix(in srgb, var(--color-blue-400) 0%, transparent) 0%,
            var(--color-blue-400) 70%
        );
    }
    .dark-gradient-background {
        background: linear-gradient(
            180deg,
            color-mix(in srgb, var(--color-gray-900) 0%, transparent) 0%,
            var(--color-gray-900) 70%
        );
    }
</style>
