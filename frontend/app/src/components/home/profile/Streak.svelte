<script lang="ts">
    import TooltipWrapper from "../../TooltipWrapper.svelte";
    import TooltipPopup from "../../TooltipPopup.svelte";

    export let streak: Streak;

    type Streak = "none" | "three" | "seven" | "thirty";

    $: show = streak !== "none";

    $: num = streakNumber(streak);

    function streakNumber(streak: Streak): 0 | 3 | 7 | 30 {
        switch (streak) {
            case "none":
                return 0;
            case "three":
                return 3;
            case "seven":
                return 7;
            case "thirty":
                return 30;
        }
    }
</script>

{#if show}
    <TooltipWrapper position="top" align="middle">
        <div slot="target" class={`icon ${streak}`}>
            {num}
        </div>
        <div let:position let:align slot="tooltip">
            <TooltipPopup {position} {align}>
                {`${streak.toUpperCase()} day streak!`}
            </TooltipPopup>
        </div>
    </TooltipWrapper>
{/if}

<style lang="scss">
    .icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 20px;
        height: 15px;
        background-repeat: no-repeat;
        @include font(bold, normal, fs-50);
        text-shadow: 0.3px 0.3px #777;
        font-size: 0.5rem;
        padding: 2px 0 0 7px;

        &.three {
            background-image: url("/assets/streaks/streak_three2.svg");
        }
        &.seven {
            background-image: url("/assets/streaks/streak_seven2.svg");
        }
        &.thirty {
            background-image: url("/assets/streaks/streak_thirty.svg");
        }
    }
</style>
