from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from lglaf import int_as_byte


def key_transform(old_key):
    new_key = b''
    for x in range(32, 0, -1):
        new_key += int_as_byte(old_key[x-1] - (x % 0x0C))
    return new_key


def xor_key(key, kilo_challenge):
    # Reserve key
    key_xor = b''
    pos = 0
    for i in range(8):
        key_xor += int_as_byte(key[pos] ^ kilo_challenge[3])
        key_xor += int_as_byte(key[pos + 1] ^ kilo_challenge[2])
        key_xor += int_as_byte(key[pos + 2] ^ kilo_challenge[1])
        key_xor += int_as_byte(key[pos + 3] ^ kilo_challenge[0])
        pos += 4
    return key_xor


def encrypt_kilo_challenge(encryption_key, kilo_challenge):
    plaintext = b''
    for k in range(0, 16):
        # Assemble 0x00 0x01 0x02 ... 0x1F byte-array
        plaintext += int_as_byte(k)
    encryption_key = key_transform(encryption_key)
    xored_key = xor_key(encryption_key, kilo_challenge)
    obj = Cipher(algorithms.AES(xored_key), modes.ECB(),
                 backend=default_backend()).encryptor()
    return obj.update(plaintext) + obj.finalize()
