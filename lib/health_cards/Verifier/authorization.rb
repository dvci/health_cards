require 'axios'
require 'crypto'
require 'base64url'
require 'KeyTypes'
require 'VerifierState'
require 'JSON'
require 'promise'


module DIDSIOP(state)

    def findState(state, event)
        if event.type == 'siop-request-created'
            return { ...state, siopRequest: event.siopRequest, siopResponse: undefined }
        if event.type == 'siop-request-received'
            return { ...state, siopResponse: event.siopResponse }

        puts ('Unrecogized event type', event)
        return state
    end

    def createSIOPReuqest(state)

        @siopState = base64url.encode(crypto.randomBytes(16))
        @siopRequestHeader = {
            @kid = state.did + '#signing-key-1'
        }
        @responseUrl = state.config.responseMode == 'formpost'
        @siopRequestPayload = VerifierState["siopRequest"]["siopRequestPayload"] = [
            {
            state= siopState,
            'iss': state.did,
            'response_type': 'id_token',
            'client_id': responseUrl,
            'claims': state.config.claimsRequired.length == 0? undefined : {
                'id_token': state.config.claimsRequired.reduce((acc, next) => [{
                    ...acc,
                    [next]: { 'essential': true }
                }), {}]
            },
            'scope': 'did_authn',
            'response_mode': state.config.responseMode,
            'response_context': state.config.responseMode == 'form_post' ? 'wallet' : 'rp',
            'nonce': base64url.encode(crypto.randomBytes(16)),
            'registration': {
                'id_token_encrypted_response_alg': state.config.skipEncryptedResponse ? undefined : 'ECDH-ES',
                'id_token_encrypted_response_enc': state.config.skipEncryptedResponse ? undefined : 'A256GCM',
                'id_token_signed_response_alg': 'ES256K',
                'client_uri': serverBase
            }
        }
        ]
        @siopRequestPayloadSigned = await state.sk.sign(siopRequestHeader, siopRequestPayload)
        @siopRequestCreated = await state.config.postRequest[`${serverBase}/siop/begin`, {
            siopRequest: siopRequestPayloadSigned
        }]
        @siopRequestQrCodeUrl = 'openid://?' + qs.encode[{
            response_type: 'id_token',
            scope: 'did_authn',
            request_uri: serverBase + '/siop/' + siopRequestPayload.state,
            client_id: siopRequestPayload.client_id
        }]
        return [{
            type: 'siop-request-created',
            siopRequest: {
                siopRequestPayload,
                siopRequestPayloadSigned,
                siopRequestQrCodeUrl,
                siopResponsePollingUrl: siopRequestCreated.responsePollingUrl
            }
        }]
    end 

    def parseSIOPResponse(idTokenReceived, state)  
        @idTokenRetrievedDecrypted = await state.ek.decrypt(idTokenRetrieved)
        @idTokenVerified = await verifyJws(idTokenRetrievedDecrypted, state.config.keyGenerators)
        if idTokenVerified
            @idToken = idTokenVerified.payload
            return ({
                type: 'siop-response-received',
                siopResponse: {
                    idTokenEncrypted: idTokenRetrieved,
                    idTokenSigned: idTokenRetrievedDecrypted,
                    idTokenPayload: idTokenVerified.payload,
                    idTokenVcs: (await Promise.all((idTokenVerified.payload?.vp?.verifiableCredential || []).map(vc => verifyJws(vc, state.config.keyGenerators))))
                        .map((jws: VerificationResult) => jws.valid && jws.payload)
                }
            })
    end
end