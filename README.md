# ifc

USAID's Intelligent Forecasting: Model Future Contraceptive Use

## Data

Source: [Kaggle](https://www.kaggle.com/darisdzakwanhoesien2/usaids-model-future-contraceptive-use)

* 156 sites
* 11 products
* 1716 sites x products (train: 1357, test: 1052)
* 45 observations from Jan 2016 to Sep 2019
* Predict 3 observations from Oct 2019 to Dec 2019
* 38,842 train data
* 3,115 test data

Additional information:

* Deadline: 8 Sept 2020
* Metrics: MASE
* 2 winners only (it will be very hard!)

## CV Strategy

4 times CV (quarterly basis)

* Jan - Mar 2019 (36 data)
* April - Jun 2019 (39 data)
* Jul - Sep 2019 (42 data)
* Oct - Nov 2018 (33 data)

8 times CV (moving monthly)

* Jan - Mar 2019
* Feb - Apr 2019
* March - May 2019
* April - Jun 2019
* May - Jul 2019
* Jun - Aug 2019
* Jul - Sep 2019
* Oct - Nov 2018

## Tasks

- [x] EDA: MVP
- [ ] EDA: Deep EDA
- [ ] Modeling: MVP (baseline)
- [ ] Modeling: single model (tree models)
- [ ] External Data


