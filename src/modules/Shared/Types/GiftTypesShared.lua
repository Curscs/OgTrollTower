local GiftTypesShared = {}

export type GiftData = {
    NextClaim: number,
    Claimed: boolean
}

export type GiftsPlayerData = {
    [string]: GiftData
}

return GiftTypesShared