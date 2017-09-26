module Fast.List5 exposing (foldr, map)


map : (a -> b) -> List a -> List b
map op list =
    chunkAndMap op list []


chunkAndMap : (a -> b) -> List a -> List (List a) -> List b
chunkAndMap op list chunks =
    case list of
        [] ->
            mapChunks op chunks []

        a :: [] ->
            mapChunks op chunks [ op a ]

        a :: b :: [] ->
            mapChunks op chunks [ op a, op b ]

        a :: b :: c :: [] ->
            mapChunks op chunks [ op a, op b, op c ]

        a :: b :: c :: d :: [] ->
            mapChunks op chunks [ op a, op b, op c, op d ]

        a :: b :: c :: d :: e :: [] ->
            mapChunks op chunks [ op a, op b, op c, op d, op e ]

        _ :: _ :: _ :: _ :: _ :: xs ->
            chunkAndMap op xs (list :: chunks)


mapChunks : (a -> b) -> List (List a) -> List b -> List b
mapChunks op chunks acc =
    case chunks of
        (a :: b :: c :: d :: e :: _) :: xs ->
            mapChunks op xs (op a :: op b :: op c :: op d :: op e :: acc)

        _ ->
            acc


foldr : (a -> b -> b) -> b -> List a -> b
foldr op acc list =
    chunkAndFoldr op acc list []


chunkAndFoldr : (a -> b -> b) -> b -> List a -> List (List a) -> b
chunkAndFoldr op acc list chunks =
    case list of
        [] ->
            foldChunks op chunks acc

        a :: [] ->
            foldChunks op chunks (op a acc)

        a :: b :: [] ->
            foldChunks op chunks (op a (op b acc))

        a :: b :: c :: [] ->
            foldChunks op chunks (op a (op b (op c acc)))

        a :: b :: c :: d :: [] ->
            foldChunks op chunks (op a (op b (op c (op d acc))))

        a :: b :: c :: d :: e :: [] ->
            foldChunks op chunks (op a (op b (op c (op d (op e acc)))))

        _ :: _ :: _ :: _ :: _ :: xs ->
            chunkAndFoldr op acc xs (list :: chunks)


foldChunks : (a -> b -> b) -> List (List a) -> b -> b
foldChunks op chunks acc =
    case chunks of
        (a :: b :: c :: d :: e :: _) :: xs ->
            foldChunks op xs (op a (op b (op c (op d (op e acc)))))

        _ ->
            acc
