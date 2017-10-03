-module(nciphr).

-export([main/1]).

-export([encrypt/2, decrypt/2,
    decode_ssh_rsa_pub/1, decode_pem/1,
    to_json/1, serialize/1]).

main(Args) ->
    Command = lists:nth(1, Args),
    case Command of
        "encrypt" ->
            ["encrypt", PathToSshRsaPublicKey, PathToMsg] = Args,
            [{RsaPublicKey, _Attrs}] = decode_ssh_rsa_pub({file, PathToSshRsaPublicKey}),
            {ok, Plaintext} = file:read_file(PathToMsg),
            Encrypted       = encrypt(Plaintext, RsaPublicKey),
            Msg             = serialize(Encrypted),
            io:format("~s~n", [Msg]);
        "decrypt" ->
            ["decrypt", PathToPrivateKey, PathToMsg] = Args,
            [Decoded] = decode_pem({file, PathToPrivateKey}),
            PrivateKey = case Decoded of
                             {_, _, not_encrypted} ->
                                 Decoded,
                                 public_key:pem_entry_decode(Decoded);
                             Decoded ->
                                 Prompt = PathToPrivateKey ++ " passphrase> ",
                                 {ok, [Passphrase]} = io:fread(Prompt, "~s"),
                                 public_key:pem_entry_decode(Decoded, Passphrase)
                         end,
            {ok, Msg} = file:read_file(PathToMsg),
            {Sealedkey, SealedIV,  Ciphertext} = deserialize(Msg),
            Plaintext = decrypt({Sealedkey, SealedIV, Ciphertext}, PrivateKey),
            io:format("~s~n", [Plaintext])
    end,
    erlang:halt(0).

encrypt(Plaintext, PublicKey) ->
    SymmetricKey = crypto:strong_rand_bytes(32),
    IV           = crypto:strong_rand_bytes(16),
    Padding      = byte_size(Plaintext),
    Ciphertext   = crypto:block_encrypt(aes_cbc256, SymmetricKey, IV, pad(Plaintext, 32)),
    SealedKey    = public_key:encrypt_public(SymmetricKey, PublicKey),
    SealedIV     = public_key:encrypt_public(IV          , PublicKey),
    {SealedKey, SealedIV, Ciphertext}.

decrypt({SealedKey, SealedIV, Ciphertext}, PrivateKey) ->
    SymmetricKey = public_key:decrypt_private(SealedKey, PrivateKey),
    IV           = public_key:decrypt_private(SealedIV,  PrivateKey),
    Plaintext    = crypto:block_decrypt(aes_cbc256, SymmetricKey, IV, Ciphertext),
    Plaintext.

pad(Value, BlockSize) when is_integer(Value) ->
    pad(erlang:integer_to_binary(Value), BlockSize);

pad(Value, BlockSize) ->
    DataSize = byte_size(Value),
    BufferSize = trunc(DataSize/BlockSize) * BlockSize + BlockSize,
    PaddingLength = BufferSize - DataSize,
    Padding = binary:list_to_bin(lists:duplicate(PaddingLength, <<"*">>)),
    binary:list_to_bin([Value, Padding]).

to_json({SealedKey, Ciphertext}) ->
    [<<"{">>,
        <<"\"ct\":\"">>, base64:encode(Ciphertext), <<"\",">>,
        <<"\"sk\":\"">>, base64:encode(SealedKey),  <<"\"">>,
        <<"}">>].

serialize({SealedKey, SealedIV, Ciphertext}) ->
    [base64:encode(SealedKey), <<"*">>,
     base64:encode(SealedIV),  <<"*">>,
     base64:encode(Ciphertext)].

deserialize(Binary) ->
    [A, T] = binary:split(Binary, <<"*">>),
    [B, C] = binary:split(T,      <<"*">>),
    {SealedKey, SealedIV, Ciphertext} = {base64:decode(A), base64:decode(B), base64:decode(C)},
    {SealedKey, SealedIV, Ciphertext}.

download_github_keys(User) ->
    inets:start(),
    ssl:start(),
    Url      = "https://github.com/" ++ User ++ ".keys",
    Response = httpc:request(get, {Url, []}, [], []),
    {ok, {_Status, _Headers, Body}} = Response,
    PublicKeys = string:split(Body, "\n"),
    PublicKeys.

decode_pem({file, FilePath}) ->
    {ok, Contents} = file:read_file(FilePath),
    decode_pem({binary, Contents});

decode_pem({binary, Binary}) ->
    Pem = public_key:pem_decode(Binary),
    Pem.

decode_ssh_rsa_pub({file, FilePath}) ->
    {ok, Contents} = file:read_file(FilePath),
    decode_ssh_rsa_pub({binary, Contents});

decode_ssh_rsa_pub({binary, Binary}) ->
    public_key:ssh_decode(Binary, public_key).
