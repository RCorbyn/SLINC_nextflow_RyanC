
params.image_dir = null

process EXTRACT_LABEL {
    errorStrategy 'ignore'
    input:
        tuple val(sample_id), path(svs_image)

    output:
        tuple val(sample_id), path("labelled_*.png"), emit: labels

    script:

    """
    label_extractor.py $svs_image

    """
}

process CROP{
    errorStrategy 'ignore'

    //magick $label_large -shave 30x20 -background "gray(70)" -deskew 60% -fuzz 35% -trim +repage -shave 5x5  
    publishDir "results/label_images"

    input:
        tuple val(sample_id), path(label_large)
    output:
        tuple val(sample_id), path("*_label_cropped.png"), emit: croppedLabs

    script:
    """
    magick ${label_large} -background "gray(60)" -deskew 90% +repage -write mpr:img \
    -morphology open octagon:2 -fuzz 35% -set option:cropbox "%@" +delete mpr:img -crop "%[cropbox]" \
    +repage -level 12%/100%/0.95 -shave 5x5 \
    "${sample_id}_label_cropped.png"

    """
}

process OCR{
    publishDir "results/renamed", mode: 'copy'
    errorStrategy 'ignore'


    input:
    tuple val(sample_id), path(cropped_img)
    output:
    tuple val(sample_id), path("*_clean.txt"), emit: ocr_txt
    path "*.png"


    script:
    """
   tesseract ${cropped_img} "${sample_id}_clean" --oem 3 -l eng --dpi 72 --psm 6 -c page_separator='' -c edges_childarea=0.2
   
   # Process the output to create a label and write to label_file
    cat "${sample_id}_clean.txt" \
    | awk NF \
    | sed -e 's/ /_/g' -e 's/[/]/_/g' -e 's/[.]/_/g' \
    | tr '\n' '-' > !{label_file}

    mv $cropped_img "`head -n 1 !{label_file}`.png"
    """
}

process RENAME{
    publishDir "results/renamed_svs", mode: 'copy'

    input:
    tuple val(sample_id), path(svs_file), path(ocr_text)

    output:
    path "*.svs"

    script:
    """
    # Process the output to create a label and write to label_file
    cat "${ocr_text}" | awk NF | sed -e 's/ /_/g' -e 's/[/]/_/g' -e 's/[.]/_/g' | tr '\n' '-' > !{label_file}

    mv ${svs_file} "`head -n 1 !{label_file}`.svs"

    """

}

workflow {

    svs_ch = Channel.fromPath( params.image_dir) 
    | map { file -> 
      def key = file.name.toString().tokenize('/.').get(0)
      return tuple(key, file)
    } 
    
    EXTRACT_LABEL(svs_ch) |  
    CROP | 
    OCR 
    
    joined_ch = svs_ch.join(OCR.out.ocr_txt)

    RENAME(joined_ch)


}
