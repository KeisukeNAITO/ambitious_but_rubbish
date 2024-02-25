import requests

# TODO: サーバ情報の取得先をハードコード以外に修正 
PROTOCOL = 'http'
SERVER = 'localhost:50021'
VOICEVOX_ENDPOINT = PROTOCOL + '://' + SERVER
# VOICEVOX_ENDPOINT = os.environ['VOICEVOX_ENDPOINT']
SPEED_SCALE = 1.4
SAMPLING_RATE = 16000

# スピーカー取得(キャラクター)
url = VOICEVOX_ENDPOINT + '/speakers'
HEADER = {'accept': 'application/json'}
res_speaker = requests.get(url, headers=HEADER)
SPEAKER = 1 # 1 is ずんだもん
speaker_info = res_speaker.json()[SPEAKER]

# モーラ生成
msg = 'こんばんは、ずんだもんです。これはテスト音声です。'
payload={
    'text' : msg,
    'speaker' : str(SPEAKER)
}
url = VOICEVOX_ENDPOINT + '/audio_query'
res_mora = requests.post(url, params=payload, headers=HEADER, data='')

res_mora_edit = res_mora.json()
res_mora_edit['speedScale'] = SPEED_SCALE
res_mora_edit['outputSamplingRate'] = SAMPLING_RATE
res_mora_edit['outputStereo'] = False

# 音声合成
url = VOICEVOX_ENDPOINT + '/synthesis'
HEADER = {
    'accept': 'audio/wav',
    'Content-Type': 'application/json'
}
payload={
    'speaker' : str(SPEAKER),
    'enable_interrogative_upspeak' : 'true'
}
body = res_mora.json()
res_audio = requests.post(url, params=payload, headers=HEADER, json=res_mora_edit)

# ファイル保存
if res_audio.status_code == 200:
    with open('./test.wav', "wb") as file:
        file.write(res_audio.content)
    print("v audio file downloaded successfully.")
else:
    print("x Failed to download the audio file.")