module Helpers.Update exposing (..)


updateWith : (subModel -> rootModel) -> (msg -> rootMsg) -> ( subModel, Cmd msg ) -> ( rootModel, Cmd rootMsg )
updateWith toModel toMsg ( subModel, cmd ) =
    ( toModel subModel
    , Cmd.map toMsg cmd
    )
