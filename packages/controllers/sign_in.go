package controllers

import (
	"encoding/hex"

	"github.com/DayLightProject/go-daylight/packages/lib"
	"github.com/DayLightProject/go-daylight/packages/utils"
)

const ASignIn = `ajax_sign_in`

type SignInJson struct {
	Address string `json:"address"`
	Result  bool   `json:"result"`
	Error   string `json:"error"`
}

func init() {
	newPage(ASignIn, `json`)
}

func (c *Controller) AjaxSignIn() interface{} {
	var result SignInJson

	//	ret := `{"result":0}`
	c.r.ParseForm()
	key := c.r.FormValue("key")
	bkey, err := hex.DecodeString(key)
	if err != nil {
		result.Error = err.Error()
		return result
	}
	sign, _ := hex.DecodeString(c.r.FormValue("sign"))
	var msg string
	switch uid := c.sess.Get(`uid`).(type) {
	case string:
		msg = uid
	default:
		result.Error = "unknown uid"
		return result
	}

	if verify, _ := utils.CheckECDSA([][]byte{bkey}, msg, sign, true); !verify {
		result.Error = "incorrect signature"
		return result
	}
	result.Result = true
	result.Address = lib.KeyToAddress(bkey)
	c.sess.Set("address", result.Address)
	log.Debug("c.r.RemoteAddr %s", c.r.RemoteAddr)
	log.Debug("c.r.Header.Get(User-Agent) %s", c.r.Header.Get("User-Agent"))

	publicKey := []byte(key)
	walletId, err := c.GetWalletIdByPublicKey(publicKey)
	if err != nil {
		result.Error = err.Error()
		return result
	}
	err = c.ExecSql("UPDATE config SET dlt_wallet_id = ?", walletId)
	if err != nil {
		result.Error = err.Error()
		return result
	}
	c.sess.Set("wallet_id", walletId)
	citizenId, err := c.GetCitizenIdByPublicKey(publicKey)
	if err != nil {
		result.Error = err.Error()
		return result
	}
	err = c.ExecSql("UPDATE config SET citizen_id = ?", citizenId)
	if err != nil {
		result.Error = err.Error()
		return result
	}
	c.sess.Set("citizen_id", citizenId)
	return result //`{"result":1,"address": "` + address + `"}`, nil
}
