Header = ""
Payload = ""
EncryptionResult = ""
SignatureResult = ""
VerificationResult = {
    valid = True,
    payload = ""
} | {
    valid = False
}
def EncryptionKey = {
    encrypt: (header: Header, payload: string) => Promise<EncryptionResult>
    decrypt: (jwe: string) => Promise<string>
    publicJwk: JsonWebKey
    privateJwk: JsonWebKey
}
def SigningKey = [{
    sign: (header: Header, payload: Payload) => Promise<SignatureResult>
    verify: (jws: string) => Promise<VerificationResult>
    publicJwk: JsonWebKey
    privateJwk: JsonWebKey
}]

def KeyGenerators = {
    generateSigningKey: (inputPublic?: JsonWebKey, inputPrivate?: JsonWebKey) => Promise<SigningKey>
    generateEncryptionKey: (inputPublic?: JsonWebKey, inputPrivate?: JsonWebKey) => Promise<EncryptionKey>
}
