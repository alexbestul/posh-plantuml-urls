function Encode6Bit($b) {
    if ($b -lt 10) { return [char](48 + $b) }
    $b -= 10
    if ($b -lt 26) { return [char](65 + $b) }
    $b -= 26
    if ($b -lt 26) { return [char](97 + $b) }
    $b -= 26
    if ($b -eq 0) { return '-' }
    if ($b -eq 1) { return '_' }
    return '?'
}

function Append3Bytes($b1, $b2, $b3) {
    $c1 = $b1 -shr 2
    $c2 = (($b1 -band 0x3) -shl 4) -bor ($b2 -shr 4)
    $c3 = (($b2 -band 0xF) -shl 2) -bor ($b3 -shr 6)
    $c4 = $b3 -band 0x3F

    # [convert]::ToString($b1, 2) + "" + [convert]::ToString($b2, 2) + "" + [convert]::ToString($b3, 2)
    # [convert]::ToString($c1, 2) + "" + [convert]::ToString($c2, 2) + "" + [convert]::ToString($c3, 2) + "" + [convert]::ToString($c4, 2)

    $r = ""
    $r += Encode6Bit ($c1 -band 0x3F)
    $r += Encode6Bit ($c2 -band 0x3F)
    $r += Encode6Bit ($c3 -band 0x3F)
    $r += Encode6Bit ($c4 -band 0x3F)

    return $r
}

function Encode64($data) {
    $r = ""

    For ($i = 0; $i -lt $data.Length; $i += 3) {
        If (($i+2) -eq $data.Length) {
            $r += Append3Bytes $data[$i] $data[$i+1] 0
        } ElseIf (($i+1) -eq $data.Length) {
            $r += Append3Bytes $data[$i] 0 0
        } Else {
            $r += Append3Bytes $data[$i] $data[$i+1] $data[$i+2]
        }
    }

    return $r
}

function Deflate($text) {
    $data = [System.Text.Encoding]::UTF8.GetBytes($text)

    $sourceStream = [System.IO.MemoryStream]::new($data)
    $destStream = [IO.MemoryStream]::new()
    $compressionStream = [System.IO.Compression.DeflateStream]::new($destStream, [IO.Compression.CompressionMode]::Compress)
    $sourceStream.CopyTo($compressionStream)
    $compressionStream.Dispose()

    return $destStream.ToArray()
}

<#
.SYNOPSIS
Encodes text into PlantUml's base64-like URL format.
.PARAMETER plantUml
The text to be encoded.
.EXAMPLE
ConvertTo-EncodedPlantUml "Alice-->Bob:Hello"
.EXAMPLE
"Alice-->Bob:Hello" | ConvertTo-EncodedPlantUml
.EXAMPLE
Get-Content example.puml | ConvertTo-EncodedPlantUml
#>
Function ConvertTo-EncodedPlantUml {
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [ValidateNotNull()]
        [String]
        $plantUml
    )
    
    $compressedText = Deflate $plantUml
    Encode64 $compressedText
}

Export-ModuleMember -Function ConvertTo-EncodedPlantUml

