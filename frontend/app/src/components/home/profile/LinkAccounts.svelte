<script lang="ts">
    import InternetIdentityLogo from "../../landingpages/InternetIdentityLogo.svelte";
    import Button from "../../Button.svelte";
    import ButtonGroup from "../../ButtonGroup.svelte";
    import LinkVariant from "svelte-material-icons/LinkVariant.svelte";
    import Alert from "svelte-material-icons/Alert.svelte";
    import { i18nKey } from "../../../i18n/i18n";
    import { iconSize } from "../../../stores/iconSize";
    import ErrorMessage from "../../ErrorMessage.svelte";
    import ModalContent from "../../ModalContent.svelte";
    import Translatable from "../../Translatable.svelte";
    import { AuthProvider, type OpenChat, type ResourceKey } from "openchat-client";
    import { createEventDispatcher, getContext } from "svelte";
    import ChooseSignInOption from "./ChooseSignInOption.svelte";
    import { configKeys } from "../../../utils/config";
    import { AuthClient } from "@dfinity/auth-client";
    // import { ECDSAKeyIdentity } from "@dfinity/identity";

    const client = getContext<OpenChat>("client");
    const dispatch = createEventDispatcher();

    export let explanations: ResourceKey[];
    export let error: string | undefined;

    type CurrentPrincipal = { kind: "current" };
    type NextPrincipal = { kind: "next"; currentPrincipal: string };
    type LinkPrincipals = { kind: "link"; currentPrincipal: string; nextPrincipal: string };
    type LinkStage = CurrentPrincipal | NextPrincipal | LinkPrincipals;

    let failed = false;
    let step: "explain" | "linking" = "explain";
    let substep: LinkStage = { kind: "current" };
    let emailInvalid = false;
    let email = "";

    $: selectedAuthProviderStore = client.selectedAuthProviderStore;

    function linkIdentity() {
        step = "linking";
    }

    function loginCurrent(ev: CustomEvent<AuthProvider>) {
        const provider = ev.detail;
        if (emailInvalid && provider === AuthProvider.EMAIL) {
            return;
        }

        localStorage.setItem(configKeys.selectedAuthEmail, email);
        selectedAuthProviderStore.set(provider);
        error = undefined;

        if (provider === AuthProvider.EMAIL) {
            // ECDSAKeyIdentity.generate().then((sk) => generateMagicLink(sk));
            console.log("TODO Logging in with email");
        } else if (provider === AuthProvider.ETH) {
            console.log("Logging in with ETH");
        } else if (provider === AuthProvider.SOL) {
            console.log("Logging in with SOL");
        } else {
            // This is the II / NFID case
            const authClient = AuthClient.create();
            authClient.then((c) => {
                c.login({
                    ...client.getAuthClientOptions(provider),
                    onSuccess: () => {
                        console.log("success", c.getIdentity());
                        const principal = c.getIdentity().getPrincipal().toString();
                        if (principal !== client.AuthPrincipal) {
                            error = "Principal mismatch";
                        } else {
                            substep = { kind: "next", currentPrincipal: principal };
                        }
                    },
                    onError: (err) => {
                        error = "we weren't able to sign into II at all";
                        console.warn("Login error from auth client: ", err);
                    },
                });
            });
        }
    }

    function loginNext() {
        if (substep.kind !== "next") return;
        const currentPrincipal = substep.currentPrincipal;

        const authClient = AuthClient.create();
        authClient.then((c) => {
            c.login({
                ...client.getAuthClientOptions(AuthProvider.II),
                onSuccess: () => {
                    const principal = c.getIdentity().getPrincipal().toString();
                    if (principal === currentPrincipal) {
                        error =
                            "The principal you are trying to link is the same as the current principal";
                    } else {
                        substep = { kind: "link", currentPrincipal, nextPrincipal: principal };
                        // Probably we can just go ahead and link at this point and we don't need another state
                    }
                },
                onError: (err) => {
                    error = "we weren't able to sign into II at all";
                    console.warn("Login error from auth client: ", err);
                },
            });
        });
    }
</script>

<ModalContent fadeDelay={0} fadeDuration={0}>
    <div slot="header" class="header">
        <LinkVariant size={$iconSize} color={"var(--txt)"} />
        <div class="title">
            <Translatable resourceKey={i18nKey("identity.linkIdentity")} />
        </div>
    </div>
    <div slot="body">
        {#if failed}
            <p class="info">
                <ErrorMessage>
                    <Translatable resourceKey={i18nKey("identity.failed")} />
                </ErrorMessage>
            </p>
        {/if}
        {#if step === "explain"}
            <div class="explain">
                <div class="explain-icon">
                    <Alert size={$iconSize} color={"var(--warn"} />
                </div>
                <div class="explain-txt">
                    {#each explanations as explanation}
                        <p class="info">
                            <Translatable resourceKey={explanation} />
                        </p>
                    {/each}
                </div>
            </div>
        {:else if step === "linking"}
            {#if substep.kind === "current"}
                <div class="info center">
                    <Translatable resourceKey={i18nKey("identity.signInCurrent")} />
                </div>
                <ChooseSignInOption
                    mode={"signin"}
                    bind:emailInvalid
                    bind:email
                    on:login={loginCurrent} />
            {:else if substep.kind === "next"}
                <div class="info">
                    <Translatable resourceKey={i18nKey("identity.signInNext")} />
                </div>
                <Button on:click={loginNext}>
                    <span class="link-ii-logo">
                        <InternetIdentityLogo />
                    </span>
                    <Translatable resourceKey={i18nKey("loginDialog.signin")} /></Button>
            {/if}
        {/if}
    </div>

    <div let:onClose slot="footer">
        <ButtonGroup>
            <Button secondary on:click={onClose}
                ><Translatable resourceKey={i18nKey("cancel")} /></Button>
            {#if step === "explain"}
                <Button secondary on:click={linkIdentity}>
                    <span class="link-ii-logo">
                        <InternetIdentityLogo />
                    </span>
                    <Translatable resourceKey={i18nKey("identity.link")} /></Button>
                <Button on:click={() => dispatch("proceed")}
                    ><Translatable resourceKey={i18nKey("identity.proceed")} /></Button>
            {:else if step === "linking"}
                <Button secondary on:click={() => (step = "explain")}
                    ><Translatable resourceKey={i18nKey("identity.back")} /></Button>
            {/if}
        </ButtonGroup>
    </div>
</ModalContent>

<style lang="scss">
    .header {
        @include font(bold, normal, fs-130, 29);
        margin-bottom: $sp4;
        display: flex;
        align-items: center;
        gap: $sp3;
    }

    .info {
        margin-bottom: $sp4;

        &.center {
            text-align: center;
        }
    }

    .explain {
        padding: $sp4;
        border: 1px solid var(--warn);
        display: flex;
        align-items: flex-start;
        gap: $sp3;
        border-radius: var(--rd);

        .explain-icon {
            flex: 0 0 25px;
        }

        .explain-txt {
            flex: auto;
        }
    }
</style>
