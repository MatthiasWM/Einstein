// ==============================
// File:			TJITLLVMOptimizeReadPass.cp
// Project:			Einstein
//
// Copyright 2014 by Paul Guyot (pguyot@kallisys.net).
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
// ==============================

#include <K/Defines/KDefinitions.h>
#include "JIT.h"

#ifdef JITTARGET_LLVM

#include "Emulator/TMemory.h"
#include "Emulator/JIT/LLVM/TJITLLVMOptimizeReadPass.h"

#include <llvm/IR/Instruction.h>

using namespace llvm;

// -------------------------------------------------------------------------- //
// Constants
// -------------------------------------------------------------------------- //

char TJITLLVMOptimizeReadPass::ID = 0;

// -------------------------------------------------------------------------- //
//  * runOnBasicBlock(BasicBlock&)
// -------------------------------------------------------------------------- //
bool
TJITLLVMOptimizeReadPass::runOnBasicBlock(BasicBlock& block) {
    IRBuilder<>(block.getContext());
	bool result = false;
	IRBuilder<> builder(block.getContext());
	SmallVector<CallInst*, 1> callInstructions;
	for (Instruction& inst : block) {
		if (isa<CallInst>(inst)) {
			CallInst* callInstruction = dyn_cast<CallInst>(&inst);
			Function* calledFunction = callInstruction->getCalledFunction();
			if (calledFunction) {
				StringRef name = calledFunction->getName();
				bool readByte = name.equals("JIT_ReadB");
				bool readWord = name.equals("JIT_Read");
				if (readWord || readByte) {
					Value* value = callInstruction->getOperand(1);
					if (isa<ConstantInt>(value)) {
						ConstantInt* constValue = dyn_cast<ConstantInt>(value);
						APInt intValue = constValue->getValue();
						KUInt32 constAddress = (KUInt32) intValue.getZExtValue();
						Value* readValue = nullptr;
						if (TMemory::IsPageInROM(constAddress)) {
							const KUInt32* pointer = mMemoryIntf.GetDirectPointerToPage(constAddress);
							if (readByte) {
								readValue = builder.getInt8(*((const KUInt8*) pointer));
							} else {
								readValue = builder.getInt32(*pointer);
							}
						} else if (constAddress >= mPage.GetVAddr() && constAddress < mPage.GetVAddr() + mPage.GetSize()) {
							const KUInt8* pointer = (const KUInt8*) mPage.GetPointer() + constAddress - mPage.GetVAddr();
							if (readByte) {
								readValue = builder.getInt8(*pointer);
							} else {
								readValue = builder.getInt32(*((const KUInt32*) pointer));
							}
						}
						
						if (readValue != nullptr) {
							builder.SetInsertPoint(callInstruction);
							builder.CreateStore(readValue, callInstruction->getOperand(2));
							callInstruction->replaceAllUsesWith(builder.getInt1(false));
							callInstructions.push_back(callInstruction);
							result = true;
						}
					}
				}
			}
		}
	}
	
	if (result) {
		for (CallInst* inst : callInstructions) {
			inst->eraseFromParent();
		}
	}

	return result;
}

#endif
