extends "res://tests/GutTestBase.gd"

const FileFinderGd = preload("res://FileFinder.gd")

func test_findFilesInDirectory():

	var files = FileFinderGd.findFilesInDirectory("res://tests/files/test1")
	assert_eq(files.size(), 4)


func test_findTxtFilesInDirectory():
	var files = FileFinderGd.findFilesInDirectory("res://tests/files/test1", ".txt")
	assert_eq(files.size(), 3)

