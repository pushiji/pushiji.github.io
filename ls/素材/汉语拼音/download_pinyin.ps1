# 汉语拼音朗读MP3批量下载脚本
# 音源：汉语拼音网 (hanyupinyin.cn)
# 命名规则：声母/韵母直接拼音名，带调音节为"拼音+声调数字.mp3"

$BaseUrl = "http://du.hanyupinyin.cn/du/pinyin/"
$DownloadDir = "汉语拼音音频_汉语拼音网"

# ========== 拼音分类 ==========

# 23个声母（本音）
$ShengMu = @('b','p','m','f','d','t','n','l','g','k','h',
             'j','q','x','zh','ch','sh','r','z','c','s','y','w')

# 24个韵母（本音）
$YunMu = @('a','o','e','i','u','v',               # 6个单韵母
           'ai','ei','ui','ao','ou','iu','ie','ve','er',  # 9个复韵母
           'an','en','in','un','vn','ang','eng','ing','ong')  # 9个鼻韵母

# 16个整体认读音节
$ZhengTiRenDu = @('zhi','chi','shi','ri','zi','ci','si',
                  'yi','wu','yu','ye','yue','yuan','yin','yun','ying')

# 常用音节（精选常用音节，覆盖所有声母+主要韵母）
$CommonSyllables = @(
    # b p m f
    'ba','bo','bi','bu','bai','bei','bao','bie','ban','ben','bin','bang','beng','bing',
    'pa','po','pi','pu','pai','pei','pao','pie','pan','pen','pin','pang','peng','ping',
    'ma','mo','mi','mu','mai','mei','mao','mie','man','men','min','mang','meng','ming',
    'fa','fo','fu','fei','fou','fan','fen','fang','feng',
    # d t n l
    'da','de','di','du','duo','dai','dui','dao','dou','diu','die',
    'dan','dun','dang','deng','ding','dong',
    'ta','te','ti','tu','tuo','tai','tui','tao','tou','tie',
    'tan','tun','tang','teng','ting','tong',
    'na','ne','ni','nu','nv','nuo','nai','nei','nao','nou','niu','nie','nve',
    'nan','nen','nin','nang','neng','ning','nong',
    'la','le','li','lu','lv','luo','lai','lei','lao','lou','liu','lie','lve',
    'lan','lin','lun','lang','leng','ling','long',
    # g k h
    'ga','ge','gu','gua','guo','gai','gui','gao','gou',
    'gan','gen','gun','gang','geng','gong','guang',
    'ka','ke','ku','kua','kuo','kai','kui','kao','kou',
    'kan','ken','kun','kang','keng','kong','kuang',
    'ha','he','hu','hua','huo','hai','hei','hui','hao','hou',
    'han','hen','hun','hang','heng','hong','huang',
    # j q x
    'ji','ju','jia','jie','jiao','jiu','jian','jin','jun','jiang','jing','jiong',
    'qi','qu','qia','qie','qiao','qiu','qian','qin','qun','qiang','qing','qiong',
    'xi','xu','xia','xie','xiao','xiu','xian','xin','xun','xiang','xing','xiong',
    # zh ch sh r
    'zha','zhe','zhu','zhua','zhuo','zhai','zhui','zhao','zhou',
    'zhan','zhen','zhun','zhang','zheng','zhong','zhuang',
    'cha','che','chu','chua','chuo','chai','chui','chao','chou',
    'chan','chen','chun','chang','cheng','chong','chuang',
    'sha','she','shu','shua','shuo','shai','shui','shao','shou',
    'shan','shen','shun','shang','sheng','shuang',
    're','ru','ruo','rui','rao','rou','ran','ren','run','rang','reng','rong',
    # z c s
    'za','ze','zu','zuo','zai','zei','zui','zao','zou',
    'zan','zen','zun','zang','zeng','zong',
    'ca','ce','cu','cuo','cai','cui','cao','cou',
    'can','cen','cun','cang','ceng','cong',
    'sa','se','su','suo','sai','sui','sao','sou',
    'san','sen','sun','sang','seng','song',
    # y w
    'ya','ye','yao','you','yan','yin','yang','ying','yong','yuan','yue','yun','yu',
    'wa','wo','wai','wei','wan','wen','wang','weng'
)

# ========== 下载函数 ==========

function Download-PinyinFile {
    param(
        [string]$FileName,
        [string]$SavePath
    )
    
    $url = $BaseUrl + $FileName
    try {
        Invoke-WebRequest -Uri $url -OutFile $SavePath -UseBasicParsing -TimeoutSec 10
        return $true
    }
    catch {
        return $false
    }
}

# ========== 主程序 ==========

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  汉语拼音朗读MP3批量下载工具" -ForegroundColor Cyan
Write-Host "  音源：汉语拼音网 (hanyupinyin.cn)" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

# 创建目录结构
$dirShengMu = Join-Path $DownloadDir "01_声母_本音"
$dirYunMu = Join-Path $DownloadDir "02_韵母_本音"
$dirZhengTi = Join-Path $DownloadDir "03_整体认读音节_四声调"
$dirCommon = Join-Path $DownloadDir "04_常用音节_四声调"

foreach ($dir in @($dirShengMu, $dirYunMu, $dirZhengTi, $dirCommon)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$total = 0
$success = 0
$failed = 0
$failedList = @()

# 1. 下载声母（本音）
Write-Host "`n【1/4】正在下载声母（23个，本音）..." -ForegroundColor Yellow
foreach ($s in $ShengMu) {
    $total++
    $filename = "$s.mp3"
    $savePath = Join-Path $dirShengMu $filename
    
    if (Download-PinyinFile -FileName $filename -SavePath $savePath) {
        $success++
        Write-Host "  ✓ $filename" -ForegroundColor Green
    }
    else {
        $failed++
        $failedList += $filename
        Write-Host "  ✗ $filename 下载失败" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 100
}

# 2. 下载韵母（本音）
Write-Host "`n【2/4】正在下载韵母（24个，本音）..." -ForegroundColor Yellow
foreach ($y in $YunMu) {
    $total++
    $filename = "$y.mp3"
    $savePath = Join-Path $dirYunMu $filename
    
    if (Download-PinyinFile -FileName $filename -SavePath $savePath) {
        $success++
        Write-Host "  ✓ $filename" -ForegroundColor Green
    }
    else {
        $failed++
        $failedList += $filename
        Write-Host "  ✗ $filename 下载失败" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 100
}

# 3. 下载整体认读音节（四个声调）
Write-Host "`n【3/4】正在下载整体认读音节（16个×4声调=64个）..." -ForegroundColor Yellow
$count = 0
foreach ($z in $ZhengTiRenDu) {
    foreach ($tone in @(1, 2, 3, 4)) {
        $total++
        $count++
        $filename = "$z$tone.mp3"
        $savePath = Join-Path $dirZhengTi $filename
        
        if (Download-PinyinFile -FileName $filename -SavePath $savePath) {
            $success++
        }
        else {
            $failed++
            $failedList += $filename
        }
        Start-Sleep -Milliseconds 50
    }
    Write-Host "  已完成 $($count/4)/16 个整体认读音节..." -ForegroundColor Gray
}

# 4. 下载常用音节（四个声调）
Write-Host "`n【4/4】正在下载常用音节（$($CommonSyllables.Count)个×4声调=$($CommonSyllables.Count*4)个）..." -ForegroundColor Yellow
$count = 0
foreach ($s in $CommonSyllables) {
    foreach ($tone in @(1, 2, 3, 4)) {
        $total++
        $filename = "$s$tone.mp3"
        $savePath = Join-Path $dirCommon $filename
        
        if (Download-PinyinFile -FileName $filename -SavePath $savePath) {
            $success++
        }
        else {
            $failed++
            $failedList += $filename
        }
        Start-Sleep -Milliseconds 30
    }
    $count++
    if ($count % 20 -eq 0) {
        Write-Host "  已完成 $count/$($CommonSyllables.Count) 个音节..." -ForegroundColor Gray
    }
}

# ========== 统计结果 ==========

Write-Host "`n==============================================" -ForegroundColor Cyan
Write-Host "  下载完成！" -ForegroundColor Green
Write-Host "  总计：$total 个文件" -ForegroundColor White
Write-Host "  成功：$success 个" -ForegroundColor Green
Write-Host "  失败：$failed 个" -ForegroundColor Red
if ($failedList.Count -gt 0) {
    Write-Host "  失败列表：$($failedList[0..19] -join ', ')" -ForegroundColor Red
    if ($failedList.Count -gt 20) {
        Write-Host "  ... 等共 $($failedList.Count) 个" -ForegroundColor Red
    }
}
Write-Host "`n  文件保存在：$(Get-Location)\$DownloadDir" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
