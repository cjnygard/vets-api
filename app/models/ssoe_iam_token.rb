# frozen_string_literal: true

# Inherits from Token class and implements differences in
# issuer, audience, and public key location
class Ssoe_Iam_Token < Token
  def public_key
    decoded_token = JWT.decode(@token_string, nil, false, algorithm: 'RS256')
    kid = decoded_token[1]['kid']
    key = nil # TODO: Fetch the correct key from JWKS url https://int.fed.eauth.va.gov/oauthe/sps/oauth/oauth20/jwks/ISAMOPe

    if key.blank?
      Rails.logger.info('Public key not found', kid: kid, exp: decoded_token[0]['exp'])
      raise error_klass("Public key not found for kid specified in token: '#{kid}'")
    end

    key
  rescue JWT::DecodeError => e
    raise error_klass("Unable to determine public key: #{e.message}")
  end

  def valid_issuer?
    payload['iss'] == nil # TODO: fetch proper values in Settings depending on environment
  end

  def valid_audience?
    payload['aud'] == nil # TODO: fetch proper values in Settings depending on environment
  end

  def identifiers
    @identifiers ||= OpenStruct.new(
      mhv_icn: payload['fediamMVIICN'],
      iam_uid: payload['fediamsecid']
    )
  end
end
