#!/bin/bash
# coding: utf-8

cd figures

############################################################
pdftoppm -png Figure3.pdf Figure3
pdf2svg Figure3.pdf Figure3.svg

#############################################################
pdftoppm -png Figure4.pdf Figure4
pdf2svg Figure4.pdf Figure4.svg

#############################################################
pdftoppm -png Figure5.pdf Figure5
pdf2svg Figure5.pdf Figure5.svg

#############################################################
pdftoppm -png FigureS2.pdf FigureS2
pdf2svg FigureS2.pdf FigureS2.svg

#############################################################
pdftoppm -png Figure1_SupportingInformation3.pdf Figure1_SupportingInformation3
pdf2svg Figure1_SupportingInformation3.pdf Figure1_SupportingInformation3.svg
pdftoppm -png Figure2_SupportingInformation3.pdf Figure2_SupportingInformation3
pdf2svg Figure2_SupportingInformation3.pdf Figure2_SupportingInformation3.svg
pdftoppm -png Figure3_SupportingInformation3.pdf Figure3_SupportingInformation3
pdf2svg Figure3_SupportingInformation3.pdf Figure3_SupportingInformation3.svg
pdftoppm -png Figure4_SupportingInformation3.pdf Figure4_SupportingInformation3
pdf2svg Figure4_SupportingInformation3.pdf Figure4_SupportingInformation3.svg

#############################################################
pdftoppm -png Figure1_SupportingInformation4.pdf Figure1_SupportingInformation4
pdf2svg Figure1_SupportingInformation4.pdf Figure1_SupportingInformation4.svg
pdftoppm -png Figure3_SupportingInformation4.pdf Figure3_SupportingInformation4
pdf2svg Figure3_SupportingInformation4.pdf Figure3_SupportingInformation4.svg
pdftoppm -png Figure4_SupportingInformation4.pdf Figure4_SupportingInformation4
pdf2svg Figure4_SupportingInformation4.pdf Figure4_SupportingInformation4.svg
pdftoppm -png Figure5_SupportingInformation4.pdf Figure5_SupportingInformation4
pdf2svg Figure5_SupportingInformation4.pdf Figure5_SupportingInformation4.svg

cd ..

