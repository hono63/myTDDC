# http://qiita.com/tjun/items/8047bf50930e6de36bdcから拝借
#

SRC_DIR=./t0
INC_DIR=./t0
TEST_DIR=./gtest
LIB_DIR=./lib
BIN_DIR=./bin
OBJ_DIR=./obj
#GTEST_DIR=../extsrc/googletest/googletest
GTEST_DIR=$(GTEST_HOME)

INCS += -I$(INC_DIR)

UNAME := $(shell uname -s)
ifeq ($(UNAME),Linux)
	  CXX=g++
  endif
  ifeq ($(UNAME),Darwin)
	  CXX=/usr/bin/clang++
  endif

CXXFLAGS = -g -Wall
SRCS    = $(SRC_DIR)/sample1.cpp
TARGET = $(LIB_DIR)/libsample1.a
OBJS  = $(addprefix $(OBJ_DIR)/, $(notdir $(SRCS:.cpp=.o)))

default: $(TARGET)
.PHONY: default

$(TARGET): $(OBJS)
	        @[ -d $(LIB_DIR) ] || mkdir -p $(LIB_DIR)
			$(AR) ruc $(TARGET) $(OBJS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	        @[ -d $(OBJ_DIR) ] || mkdir -p $(OBJ_DIR)
			$(CXX) $(CXXFLAGS) $(INCS) -o $@ -c $<


TEST_SRCS = $(TEST_DIR)/sample1_unittest.cc
TEST_TARGET = $(BIN_DIR)/sample1_unittest.out
TEST_OBJS  = $(addprefix $(OBJ_DIR)/, $(notdir $(TEST_SRCS:.cc=.o)))
	LIBS += -L$(LIB_DIR)
	LIBS += -lsample1

CPPFLAGS += -isystem $(GTEST_DIR)/include
CXXFLAGS = -g -Wall -Wextra -pthread

# All Google Test headers.  Usually you shouldn't change this
# definition.
GTEST_HEADERS = $(GTEST_DIR)/include/gtest/*.h \
                $(GTEST_DIR)/include/gtest/internal/*.h
GTEST_SRCS_ = $(GTEST_DIR)/src/*.cc $(GTEST_DIR)/src/*.h $(GTEST_HEADERS)

# For simplicity and to avoid depending on Google Test's
# implementation details, the dependencies specified below are
# conservative and not optimized.  This is fine as Google Test
# compiles fast and for ordinary users its source rarely changes.

$(OBJ_DIR)/gtest-all.o : $(GTEST_SRCS_)
		$(CXX) $(CPPFLAGS) -I$(GTEST_DIR) $(CXXFLAGS) -c \
		 -o $@ $(GTEST_DIR)/src/gtest-all.cc

$(OBJ_DIR)/gtest_main.o : $(GTEST_SRCS_)
		$(CXX) $(CPPFLAGS) -I$(GTEST_DIR) $(CXXFLAGS) -c \
		-o $@ $(GTEST_DIR)/src/gtest_main.cc

$(LIB_DIR)/gtest.a : $(OBJ_DIR)/gtest-all.o
		$(AR) $(ARFLAGS) $@ $^

$(LIB_DIR)/gtest_main.a : $(OBJ_DIR)/gtest-all.o $(OBJ_DIR)/gtest_main.o
		$(AR) $(ARFLAGS) $@ $^

test: $(TEST_TARGET)
.PHONY: test

$(TEST_TARGET): $(TARGET) $(TEST_OBJS) $(LIB_DIR)/gtest_main.a
		@[ -d $(BIN_DIR) ] || mkdir -p $(BIN_DIR)
		$(CXX) $(LDFLAGS) -o $@ $(TEST_OBJS) \
		$(LIB_DIR)/gtest_main.a $(LIBS) -lpthread

$(OBJ_DIR)/%.o: $(TEST_DIR)/%.cc $(GTEST_HEADERS)
		@[ -d $(OBJ_DIR) ] || mkdir -p $(OBJ_DIR)
		$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCS) -o $@ -c $<

clean:
		rm -f $(TARGET) $(TEST_TARGET) $(OBJS) $(TEST_OBJS)
