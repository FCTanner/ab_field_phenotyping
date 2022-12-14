# ab_field_phenotyping
Methods for processing of data acquired with a ground-based phenotyping platform [(Field Explorer)](https://www.phenokey.com/applications/rover-based-field-phenotyping) to screen and detect Aschochyta Blight of chickpea 

## Description

Code and data underlying <mark>thesis chapter in:</mark>

![](https://github.com/FCTanner/ab_field_phenotyping/blob/main/reg_2020_spectrum_importance.png)

## Getting started

### Contents

- [Data](https://github.com/FCTanner/ab_hsi_phenotyping/tree/main/raw_data)
	* Raw FieldExplorer data <mark>available via Pawsey</mark>
	* Hyperspectral data (for preprocessing methods, see https://github.com/FCTanner/ab_hsi_phenotyping)
	* Lidar data
	* Visual scores

- [EDA](https://github.com/FCTanner/ab_field_phenotyping/tree/main/eda)

- [Extraction of vegetation indices](https://github.com/FCTanner/ab_field_phenotyping/tree/main/vi_extraction)

- [Prediction of DI and variable selection](https://github.com/FCTanner/ab_field_phenotyping/tree/main/predict_DI)

- [Classification of treatments and variable selection](https://github.com/FCTanner/ab_field_phenotyping/tree/main/classify_treatment)


### Data dictionary

#### [2020 hyperspectral data](https://github.com/FCTanner/ab_field_phenotyping/blob/main/data/2020/hyperspec_full.csv)
#### [2020 hyperspectral data binned at FWHM](https://github.com/FCTanner/ab_field_phenotyping/blob/main/data/2020/hyperspec_FWHM.csv)
#### [2020 hyperspectral data binned at double FWHM](https://github.com/FCTanner/ab_field_phenotyping/blob/main/data/2020/hyperspec_double_FWHM.csv)

#### [2022 hyperspectral data](https://github.com/FCTanner/ab_field_phenotyping/blob/main/data/2022/hyperspec_full.csv)
#### [2022 hyperspectral data binned at FWHM](https://github.com/FCTanner/ab_field_phenotyping/blob/main/data/2022/hyperspec_FWHM.csv)
#### [2022 hyperspectral data binned at double FWHM](https://github.com/FCTanner/ab_field_phenotyping/blob/main/data/2022/hyperspec_double_FWHM.csv)

| variable             | class     | description                                      |
|----------------------|-----------|--------------------------------------------------|
| plot_id_fe           | character | Plot ID                                          |
| wavelength_bin       | double    | Waveband (or center wavelengths of binned bands) |
| reflectance_smoothed | double    | Raw reflectance value                            |
| reflectance_raw      | double    | Smoothed reflectance value                       |

#### [2020 lidar data](https://github.com/FCTanner/ab_field_phenotyping/blob/main/data/2020/lidar_traits.csv)
#### [2022 lidar data](https://github.com/FCTanner/ab_field_phenotyping/blob/main/data/2022/lidar_traits.csv)

| variable    | class     | description                                 |
|-------------|-----------|---------------------------------------------|
| plot_id_fe  | character | Plot ID                                     |
| biomass     | double    | Biomass (Sum of plant voxel volumes)        |
| groundcover | double    | Ratio of covered ground per scanned surface |

#### [2020 visual scores](https://github.com/FCTanner/ab_field_phenotyping/blob/main/data/2020/scores.csv)

| variable         | class     | description                     |
|------------------|-----------|---------------------------------|
| rep              | double    | Replicate                       |
| row              | double    | Experimental design, row        |
| bay              | double    | Experimental design, bay        |
| plot_id_fe       | character | Plot ID                         |
| treatment        | character | Treatment                       |
| pad              | double    | Percent Ascochyta blight damage |
| experiment       | character | Treatment                       |
| id_with_controls | character |           Genotype ID           |
| type             | character | Genotype group                  |

#### [2022 visual scores](https://github.com/FCTanner/ab_field_phenotyping/blob/main/data/2022/scores.csv)
| variable         | class     | description                          |
|------------------|-----------|--------------------------------------|
| scoring_order    | double    | Order in which trays were scored     |
| tray_id          | character | Tray ID                              |
| pad              | double    | Percent Ascochyta blight damage      |
| plots            | double    | Experimental design, Plot number     |
| splots           | double    | Experimental design, sub-unit number |
| block            | double    | Experimental design, Block           |
| treatment        | character | Treatment                            |
| id_with_controls | character |              Genotype ID             |
## Authors

Florian Tanner 

## Version history

## Licence

## Acknowledgements