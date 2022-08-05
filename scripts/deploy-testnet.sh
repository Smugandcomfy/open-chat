
set -euxo pipefail

export DFX_NETWORK=small12
DFX_IDENTITY=openchat
DUMMY_ID="rturd-qaaaa-aaaaf-aabaq-cai"
LEDGER_CANISTER_ID="ryjl3-tyaaa-aaaaa-aaaba-cai"

PROVIDER="$(jq -r '.networks[env.DFX_NETWORK].providers[0]' dfx.json)"

NETWORK="$DFX_NETWORK"
IC_URL="$PROVIDER"
IDENTITY="$DFX_IDENTITY"
OPEN_STORAGE_INDEX_CANISTER_ID="$DUMMY_ID"
LEDGER_CANISTER_ID="$LEDGER_CANISTER_ID"
TEST_MODE=true

for canister in user_index group_index notifications online_users_aggregator callback proposals_bot
do
    dfx canister --network "$DFX_NETWORK" create "$canister"
done

./scripts/deploy.sh "$NETWORK" "$IC_URL" "$IDENTITY" "$OPEN_STORAGE_INDEX_CANISTER_ID" "$LEDGER_CANISTER_ID" "$TEST_MODE"
