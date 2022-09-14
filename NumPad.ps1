class NumPad : System.Windows.Forms.PictureBox {
    # プロパティ定義
    [string] $Caption                                   # キャプション
    [string] $Value                                     # 数値
    [int] $TextLength                                   # 文字列の最大長

    # 非表示プロパティ定義
    hidden [int] $X                                     # コントロール内のマウス座標X
    hidden [int] $Y                                     # コントロール内のマウス座標Y
    hidden [int] $Index                                 # 現在のボタンインデックス
    hidden [System.Drawing.Rectangle] $DigitalRect      # デジタル表示部の矩形エリア
    hidden [System.Drawing.Rectangle] $CloseBtn         # 閉じるボタンのパラメータ
    hidden [int] $ButtonSize                            # ボタンの円のサイズ(通常)
    hidden [int] $ButtonSize2                           # ボタンの円のサイズ(フォーカス)
    hidden [bool] $Click                                # クリックの状態
    hidden [string[]] $Buttons                          # ボタンパラメータ

    hidden [object] $Brushes                            # ブラシ保存用
    hidden [object] $Pens                               # ペン保存用
    hidden [System.Drawing.Bitmap] $Bmp                 # ビットマップオブジェクト
    hidden [System.Drawing.Graphics] $Gp                # ビットマップ描画用グラフィックオブジェクト
    hidden [System.Drawing.StringFormat] $Format        # ボタンの文字列配置
    hidden [System.Drawing.StringFormat] $DigitalFormat # デジタル表示部の文字列配置
    hidden [System.Drawing.Font] $CaptionFont           # キャプションのフォント
    hidden [System.Drawing.Font] $ButtonFont            # ボタンのフォント(通常)
    hidden [System.Drawing.Font] $ButtonFont2           # ボタンのフォント(フォーカス)
    hidden [object]$Scale                               # 描画スケール

    # コンストラクタ
    NumPad() : base() {
        $this.Init()
     }
 
    # コンストラクタ(位置指定)
    NumPad([int]$left,[int]$top) : base(){
        $base = [System.Windows.Forms.PictureBox] $this
        $base.Location = New-Object System.Drawing.Point($left,$top)
        $this.Init()
        
    }

    # コンストラクタ(位置・サイズ指定)
    NumPad([int]$left,[int]$top,[int]$width,[int]$height) : base(){
        $base = [System.Windows.Forms.PictureBox] $this
        $base.Location = New-Object System.Drawing.Point($left,$top)
        $this.Init($width,$height)
        
    }

    # コントロールを開く
    Open(){
        if(-not [int]::TryParse($this.Text,[ref]$null)){
            $this.Text = ""
        }
        $this.Visible = $true
    }

    # コントロールを開く(文字列指定)
    Open([string]$txt){
        $this.Text = $txt
        $this.Open()
    }

    # コントロールを閉じる
    Close(){
        $this.Visible = $false
    }

    # クラス初期化処理
    hidden Init(){
        $this.Init(200,240)        
    }

    # クラス初期化処理(サイズ指定)
    hidden Init([int]$width,[int]$height){
        # プロパティ初期化
        $this.Text = ""
        $this.Caption = ""
        $this.Value = 0
        $this.TextLength = 9
        $this.X = 0
        $this.Y = 0
        $this.DigitalRect = New-Object System.Drawing.Rectangle(100,90,600,120)
        $this.CloseBtn = New-Object System.Drawing.Rectangle(720,0,79,79)
        $this.ButtonSize = 75
        $this.ButtonSize2 = 85
        $this.Buttons = @(
             "7", "8", "9",
             "4", "5", "6",
             "1", "2", "3",
            "BS", "0","AC"
        )
        $this.Brushes = @{
            BG      = New-Object System.Drawing.SolidBrush("#AAAAFF")
            BASE    = new-object System.Drawing.SolidBrush("#4444AA")
            CELL    = New-Object System.Drawing.SolidBrush("#6666CC")
            SCELL   = New-Object System.Drawing.SolidBrush("#FFFFFF")
            RCELL   = New-Object System.Drawing.SolidBrush("#AAAADD")
            CLOSE   = New-Object System.Drawing.SolidBrush("#FFAAAA")
            SCLOSE  = New-Object System.Drawing.SolidBrush("#FF0000")
        }
        $this.Pens = @{
            SLINE   = New-Object System.Drawing.Pen("#FFFFFF")
            RLINE   = New-Object System.Drawing.Pen("#AAAADD")
            CLOSE   = New-Object System.Drawing.Pen("#FF0000")
            SCLOSE  = New-Object System.Drawing.Pen("#FFDDDD")
        }
        $this.Pens.SLINE.Width = 8
        $this.Pens.RLINE.Width = 8
        $this.Pens.CLOSE.Width = 6
        $this.Pens.SCLOSE.Width = 6
        $this.Bmp = New-Object System.Drawing.Bitmap(800,960)
        $this.Gp = [System.Drawing.Graphics]::FromImage($this.Bmp)
        $this.Format = New-Object System.Drawing.StringFormat
        $this.Format.Alignment = [System.Drawing.StringAlignment]::Center
        $this.Format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $this.DigitalFormat = New-Object System.Drawing.StringFormat
        $this.DigitalFormat.Alignment = [System.Drawing.StringAlignment]::Far
        $this.DigitalFormat.LineAlignment = [System.Drawing.StringAlignment]::center
        $this.CaptionFont = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",48,[System.Drawing.FontStyle]::Bold
        )
        $this.ButtonFont = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",48,[System.Drawing.FontStyle]::Bold
        )
        $this.ButtonFont2 = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",60,[System.Drawing.FontStyle]::Bold
        )
        $this.Scale = $this.GetScale($width,$height,800,960)
        # PictureBox初期化
        $base = [System.Windows.Forms.PictureBox] $this
        $base.Size = New-Object System.Drawing.Size($width,$height)
        $base.BorderStyle = [System.Windows.Forms.BorderStyle]::None
        $base.BackColor = [System.Drawing.Color]::Transparent
        $base.Font = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",80,[System.Drawing.FontStyle]::Bold
        )
        $base.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
        # イベントハンドラ登録
        $base.Add_Paint({$this.OwnerDraw($_)})
        $base.Add_MouseDown({$this.MouseDown($_)})
        $base.Add_MouseUp({$this.MouseUp()})
        $base.Add_MouseMove({$this.MouseMove($_)})
        $base.Add_MouseLeave({$this.MouseLeave()})
        $base.Add_VisibleChanged({$this.VisibleChanged()})
    }

    # ボタンが押されたとき
    hidden MouseDown([System.Windows.Forms.MouseEventArgs]$e){
        switch($e.Button){
            ([System.Windows.Forms.MouseButtons]::Left){
                if(-not $this.Click){
                    if($this.Index -ge 0){
                        switch($this.Buttons[$this.Index]){
                            "BS"{
                                if($this.Text.Length -gt 0){
                                    $this.Text = $this.Text.SubString(0,$this.Text.Length - 1)
                                }        
                            }
                            "AC"{$this.Text = ""}
                            default{
                                if($this.TextLength -gt 9){
                                    $this.TextLength = 9
                                }
                                if($this.Text.Length -lt $this.TextLength){
                                    $this.Text += $_
                                }
                            }
                        }
                        if([int]::TryParse($this.text,[ref]$null)){
                            $this.Value = [Convert]::ToInt32($this.Text)
                        }else{
                            $this.Value = 0
                        }
                    }
                }
                $this.Click = $true
                $this.Invalidate()
                if($this.ChkInRect($this.CloseBtn)){
                    $this.Close()
                }
            }
            ([System.Windows.Forms.MouseButtons]::Right){
                $this.Close()
            }
        }
    }
    
    # ボタンが離されたとき
    hidden MouseUp(){
        $this.Click = $false
    }

    # マウスが移動したとき
    hidden MouseMove([System.Windows.Forms.MouseEventArgs]$e){
        $this.X = $e.X * $this.Scale.X
        $this.Y = $e.Y * $this.Scale.Y
        $this.Invalidate()
    }

    # マウスがコントロールの外に出たとき
    hidden MouseLeave(){
        # 保持しているマウス情報を初期化
        $this.X = 0
        $this.Y = 0
        $this.Click = $false
        $this.Invalidate()
    }

    # Visibleプロパティが変更されたとき
    hidden VisibleChanged(){
        if($this.Visible){
            $this.Invalidate()
        }
    }
    
    # オーナードロー(独自描画)処理
    hidden OwnerDraw([System.Windows.Forms.PaintEventArgs] $e){
        $base = [System.Windows.Forms.PictureBox] $this
        $c = $this.Center
        $g = $this.Gp
        $s = $this.Bmp
        # 背景
        $g.FillRectangle($this.Brushes.BG,0,0,$s.Width,$s.Height)
        # キャプション
        if($this.Caption -ne ""){
            $g.FillRectangle($this.Brushes.CELL,0,0,$s.Width,79)
            $g.DrawString($this.Caption,$this.CaptionFont,$this.Brushes.SCELL,$c.X,44,$this.Format)
        }
        # 閉じるボタン
        $cb = $this.CloseBtn
        if($this.ChkInRect($cb)){
            $b = $this.Brushes.SCLOSE
            $p = $this.Pens.SCLOSE
        }else{
            $b = $this.Brushes.CLOSE
            $p = $this.Pens.CLOSE
        }
        $r = [Convert]::ToInt32([double]0.75 * $cb.Width)
        $g.FillRectangle($b,$cb)
        $g.DrawLine($p,$cb.Left + $r,$cb.Top + $r,$cb.Left + $cb.Width - $r,$cb.Top + $cb.Height - $r)
        $g.DrawLine($p,$cb.Left + $r,$cb.Top + $cb.Height - $r,$cb.Left + $cb.Width - $r,$cb.Top + $r)
        # ボタン表示部
        $this.Index = -1
        for($i = 0 ; $i -lt $this.Buttons.Count ; $i++){
            $bx = 200 + ($i % 3) * 200
            $by = 320 + [Convert]::ToInt32([math]::Floor($i / 3)) * 175
            if($this.ChkInCircle($bx,$by,$this.ButtonSize)){
                $s = $this.ButtonSize2
                $b = $this.Brushes.SCELL
                $f = $this.ButtonFont2
                $fb = $this.Brushes.BASE
                $this.Index = $i
            }else{
                $s = $this.ButtonSize
                $b = $this.Brushes.CELL
                $f = $this.ButtonFont
                $fb = $this.Brushes.BG
            }
            $g.FillPie($b,$bx - $s,$by - $s,$s * 2,$s * 2,0,360)
            $g.DrawString($this.Buttons[$i],$f,$fb,$bx,$by + 6,$this.Format)
        }
        # デジタル部
        $d = $this.DigitalRect
        $g.FillRectangle($this.Brushes.BASE,$d)
        $g.DrawString($this.Text,$base.Font,$this.Brushes.RCELL,704,$d.Top + $d.Height / 2 + 8,$this.DigitalFormat)
        $base.Image = $this.Bmp
    }

    # 2点間の距離を算出
    hidden [double] GetDistance([int]$x1,[int]$y1,[int]$x2,[int]$y2){
        $xp = [math]::Pow([math]::Abs($x2 - $x1),2)
        $yp = [math]::Pow([math]::Abs($y2 - $y1),2)
        return [math]::Sqrt($xp + $yp)
    }

    # ビットマップのサイズに対するUIサイズの縮尺を返す
    hidden [object]GetScale([int]$w1,[int]$h1,[int]$w2,[int]$h2){
        return @{X = ($w2 / $w1) ; Y = ($h2 / $h1)}
    }

    # マウスカーソルが矩形範囲内にあるかを判定
    hidden [bool]ChkInRect([System.Drawing.Rectangle]$r){
        $cx = $this.X -ge $r.Left -and $this.X -lt $r.Left + $r.Width
        $cy = $this.Y -lt $r.Top + $r.Height -and $this.Y -ge $r.Top
        return ($cx -and $cy)
                
    }

    # 円領域内にマウスカーソルがあるかを判定
    hidden [bool]ChkInCircle([int]$cx,[int]$cy,[int]$r){
        return ($this.GetDistance($this.X,$this.Y,$cx,$cy) -lt $r)
    }
}
