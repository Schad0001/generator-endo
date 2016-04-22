fs          = require 'fs'
_           = require 'lodash'
MeshbluHTTP = require 'meshblu-http'
Encryption  = require 'meshblu-encryption'
path        = require 'path'

userDeviceConfigGenerator = require '../user-device-config-generator'

class CredentialsDevice
  constructor: (meshbluConfig) ->
    {@uuid, @privateKey} = meshbluConfig
    @meshblu = new MeshbluHTTP meshbluConfig

  createUserDevice: ({authorizedUuid}, callback) =>
    @meshblu.register userDeviceConfigGenerator({authorizedUuid}), callback

  getUuid: => @uuid

  update: ({authorizedUuid, clientSecret}, callback) =>
    encryption = Encryption.fromJustGuess @privateKey
    update =
      $set:
        'endo.authorizedUuid': authorizedUuid
        'endo.clientSecret'  : encryption.encryptOptions clientSecret

    @meshblu.updateDangerously @uuid, update, callback

  getUserDevices: (callback) =>
    @meshblu.subscriptions @uuid, (error, subscriptions) =>
      return callback error if error?
      return callback null, @_userDevicesFromSubscriptions subscriptions

  _userDevicesFromSubscriptions: (subscriptions) =>
    _(subscriptions)
      .filter type: 'message.received'
      .map ({uuid}) => {uuid}
      .value()



module.exports = CredentialsDevice