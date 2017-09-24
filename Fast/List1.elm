module Fast.List1 exposing (foldr, map)


map : (a -> b) -> List a -> List b
map op list =
    chunkAndMap op list []


chunkAndMap : (a -> b) -> List a -> List (List a) -> List b
chunkAndMap op list chunks =
    case list of
        a :: [] ->
            mapChunks op chunks [ op a ]

        [] ->
            mapChunks op chunks []

        _ :: xs ->
            chunkAndMap op xs (list :: chunks)


mapChunks : (a -> b) -> List (List a) -> List b -> List b
mapChunks op chunks acc =
    case chunks of
        (a :: _) :: xs ->
            mapChunks op xs (op a :: acc)

        _ ->
            acc


foldr : (a -> b -> b) -> b -> List a -> b
foldr op acc list =
    chunkAndFoldr op acc list []


chunkAndFoldr : (a -> b -> b) -> b -> List a -> List (List a) -> b
chunkAndFoldr op acc list chunks =
    case list of
        a :: [] ->
            foldChunks op chunks (op a acc)

        [] ->
            foldChunks op chunks acc

        _ :: xs ->
            chunkAndFoldr op acc xs (list :: chunks)


foldChunks : (a -> b -> b) -> List (List a) -> b -> b
foldChunks op chunks acc =
    case chunks of
        (a :: _) :: xs ->
            foldChunks op xs (op a acc)

        _ ->
            acc
