# Remove/reload, to ensure that there isn't an existing module of the same name loaded.
Remove-Module Posh-Plantuml-Urls -Force
Import-Module $PSScriptRoot\Posh-Plantuml-Urls.psm1 -Force

InModuleScope posh-plantuml-urls {
    Describe 'ConvertTo-EncodedPlantUml' {

        # Sample text should be encoded using the plantuml jar's -encodeurl option
        # to create a baseline to test against.
        #
        # The plantuml.jar encodeurl implementation works diferentely from the
        # reference javascript/php encoding implementations provided on the plantuml
        # website. The online reference implementations encode all text exactly as
        # provided. The jar implementation only encodes text contained in
        # @startuml/@enduml blocks. Since the jar implementation searches for
        # blocks, it also provides a seperate encoded string for each hash within a
        # single input file. Incidentally, this means that the block markers are
        # required by the jar's algorithm (unless you are using the -pipe option).
        #
        # The jar implementation does not enclude the @startuml/@enduml markers in
        # its encoded content. That means that encoding
        #
        # ---
        # @startuml
        # Alice-->Bob:Hello
        # @enduml
        # ---
        #
        # using the jar file will yield the same result as encoding
        #
        # ---
        # Alice-->Bob:Hello
        # ---
        #
        # using one of the reference algorithms.
        #
        # Currently (I may decide to change it in the future) the posh-plantuml-urls
        # implementation behaves like the reference implementations, so the
        # @startuml/@enduml markers should be omitted from the input to
        # ConvertTo-EncodedPlantUml, but included in the input to plantuml.jar.
        $rawSampleText = 'Alice-->Bob:Hello'
        $encodedSampleText = 'Syp9J4xLrRLpoa-oyaZDoSa70000'

        It 'Encodes the sample text from pipeline input' {
            $rawSampleText | ConvertTo-EncodedPlantUml | Should Be $encodedSampleText
        }
        
        It 'Encodes the sample text from named argument input' {
            ConvertTo-EncodedPlantUml -plantUml $rawSampleText | Should Be $encodedSampleText
        }
        
        It 'Encodes the sample text from unnamed argument input' {
            ConvertTo-EncodedPlantUml $rawSampleText | Should Be $encodedSampleText
        }
    }
}