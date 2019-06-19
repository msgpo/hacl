let pp_result ppf = function
  | Ok result ->
      Cstruct.hexdump_pp ppf result
  | Error e ->
      Format.fprintf ppf "error: %a@." Hacl_x25519.pp_error e

let get_ok = function
  | Ok x ->
      x
  | Error _ ->
      assert false

let test ~name ~pub ~priv =
  let result = Hacl_x25519.key_exchange priv pub in
  Format.printf "%s:@,%a@," name pp_result result

let priv_key_of_hex s =
  get_ok (Hacl_x25519.priv_key_of_cstruct (Cstruct.of_hex s))

let too_short = Cstruct.create 31

let too_long = Cstruct.create 33

(** Test private-to-public conversion and key exchange.
    Data comes from RFC7748 6.1 and Wycheproof. *)
let run_tests () =
  let alice_private =
    priv_key_of_hex
      {| 77076d0a7318a57d3c16c17251b26645
         df4c2f87ebc0992ab177fba51db92c2a |}
  in
  test ~name:"public too short" ~priv:alice_private ~pub:too_short;
  test ~name:"public too long" ~priv:alice_private ~pub:too_long;
  let alice_public = Hacl_x25519.public alice_private in
  Format.printf "alice_public:@.%a" Cstruct.hexdump_pp alice_public;
  let bob_private =
    priv_key_of_hex
      {| 5dab087e624a8a4b79e17f8b83800ee6
         6f3bb1292618b6fd1c2f8b27ff88e0eb |}
  in
  let bob_public = Hacl_x25519.public bob_private in
  Format.printf "bob_public:@.%a" Cstruct.hexdump_pp bob_public;
  test ~name:"pub_a * priv_b" ~pub:alice_public ~priv:bob_private;
  test ~name:"pub_b * priv_a" ~pub:bob_public ~priv:alice_private;
  let low_order_pub =
    Cstruct.of_hex
      {| e0eb7a7c3b41b8ae1656e3faf19fc46a
         da098deb9c32b1fd866205165f49b800 |}
  in
  let low_order_priv =
    priv_key_of_hex
      {| 10255c9230a97a30a458ca284a629669
         293a31890cda9d147febc7d1e22d6bb1 |}
  in
  test ~name:"low order point" ~pub:low_order_pub ~priv:low_order_priv

let () = run_tests ()
