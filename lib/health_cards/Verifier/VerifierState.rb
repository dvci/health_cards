require 'KeyTypes'
ClaimType = 'https://healthwallet.cards#covid19' | 'https://healthwallet.cards#immunization' | 'https://healthwallet.cards#tdap'
SiopResponseMode = 'form_post' | 'fragment'

module VerifierState 
    ek: EncryptionKey
    sk: SigningKey
    did: String;
    didDebugging?: Any;
    config: {
        role: string;
        skipVcPostToServer?: boolean;
        claimsRequired: ClaimType[];
        reset?: boolean;
        responseMode: SiopResponseMode;
        displayQr?: boolean;
        postRequest: (url: string, jsonBody: any) => Promise<any>;
        serverBase: string;
        keyGenerators: KeyGenerators;
        skipEncryptedResponse?: boolean;
    };
    siopRequest?: {
        siopRequestPayload: {
            response_type: 'id_token';
            scope: String;
            nonce: String;
            registration: {
                id_token_encrypted_response_alg?: String; 
                id_token_encrypted_response_enc?: String; 
                id_token_signed_response_alg: String;
                client_uri: string;
            };
            response_mode: 'form_post' | 'fragment' | 'query';
            response_context?: 'wallet' | 'rp';
            claims?: any;
            client_id: string;
            state: string;
            iss: string;
        };
        siopRequestPayloadSigned: string;
        siopRequestQrCodeUrl: string;
        siopResponsePollingUrl: string;
    };
    siopResponse?: {
        idTokenRaw: string;
        idTokenDecrypted: string;
        idTokenPayload: {
            did: string;
        };
        idTokenVcs?: any[]
    };
    issuedCredentials?: string[];
    fragment?: {
        id_token: string;
        state: string;
    };
end